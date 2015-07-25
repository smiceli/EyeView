class BHSImageViewer < UIView
  attr_accessor :delegate
  attr_accessor :image

  def initWithFrame(frame)
    if super
      self.userInteractionEnabled = true
      self.add_scroll_view
      self.add_image_view
      self.add_dismiss_gesture
    end
    self
  end

  def add_scroll_view
    @scroll_view = UIScrollView.alloc.init
    @scroll_view.minimumZoomScale = 1.0
    @scroll_view.maximumZoomScale = 10.0
    @scroll_view.bouncesZoom = true
    @scroll_view.delegate = self

    Motion::Layout.new do |layout|
      layout.view self
      layout.subviews "scroll" => @scroll_view
      layout.vertical "|[scroll]|"
      layout.horizontal "|[scroll]|"
    end
  end

  def image_orientation(image)
    if image.imageOrientation == UIImageOrientationUp
      :landscape
    elsif image.imageOrientation == UIImageOrientationDown
      :landscape
    elsif image.imageOrientation == UIImageOrientationLeft
      :portrait
    elsif image.imageOrientation == UIImageOrientationRight
      :portrait
    else
      :unknown
    end
  end

  def orientation
    o = UIApplication.sharedApplication.statusBarOrientation
    if o == UIInterfaceOrientationLandscapeLeft
      :landscape
    elsif o == UIInterfaceOrientationLandscapeRight
      :landscape
    elsif o == UIInterfaceOrientationPortrait
      :portrait
    elsif o == UIInterfaceOrientationPortraitUpsideDown
      :portrait
    else
      :unknown
    end
  end

  def initial_frame_for_image(image, orientation)
    image_aspect = image.size.width / image.size.height
    frame = self.bounds

    if orientation == :landscape
      frame.size.height = frame.size.width / image_aspect
    else
      frame.size.width = frame.size.height * image_aspect
    end
    frame
  end

  def center_in_scroll_view(view)
    deltax = view.frame.size.width - self.bounds.size.width
    deltay = view.frame.size.height - self.bounds.size.height
    @scroll_view.contentOffset = CGPointMake(deltax/2.0, deltay/2.0)
  end

  def set_minimum_zoom_scale
    if self.orientation == self.image_orientation(@image_view.image)
      @scroll_view.minimumZoomScale = 1
    else
      if self.orientation == :landscape
        @scroll_view.minimumZoomScale = @original_frame.size.width / self.frame.size.height
      else
        @scroll_view.minimumZoomScale = @original_frame.size.height / self.frame.size.width
      end
    end
  end

  def adjust_zoom_scale_if_needed
    if @scroll_view.zoomScale < @scroll_view.minimumZoomScale
      @scroll_view.zoomScale = @scroll_view.minimumZoomScale
    end
  end

  def frame_for_image(image)
    frame = @image_view.frame
    if self.image_orientation(image) != self.orientation
      x = frame.origin.x
      frame.origin.x = frame.origin.y
      frame.origin.y = x

      w = frame.size.width
      frame.size.width = frame.size.height
      frame.size.height = w
    end
    frame
  end

  def setup_initial_image_view
    if @layed_out_image != @image_view.image
      @layed_out_image = @image_view.image

      @image_view.frame = self.initial_frame_for_image @image_view.image, self.orientation
      self.center_in_scroll_view @image_view
      @scroll_view.zoomScale = 1.0
      @original_frame = self.frame_for_image @image_view.image
    end
  end

  def layoutSubviews
    super
    self.setup_initial_image_view
    self.set_minimum_zoom_scale
    self.adjust_zoom_scale_if_needed

    NSLog("zoom: %@ min:%@", @scroll_view.zoomScale, @scroll_view.minimumZoomScale)
  end

  def add_image_view
    @image_view = UIImageView.alloc.init
    @scroll_view.addSubview @image_view
  end

  def image=(image)
    @image_view.image = image
  end

  def add_dismiss_gesture
    g = UITapGestureRecognizer.alloc.initWithTarget self, action: :"dismiss:"
    g.numberOfTapsRequired = 2
    self.addGestureRecognizer g
  end

  def dismiss(recognizer)
    @delegate.dismiss_image_viewer if @delegate
  end

  def viewForZoomingInScrollView(scrollview)
    @image_view
  end
end
