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
    puts "adding scroll view"
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

  def layoutSubviews
    super
    if @image_view.frame.size.width == 0
      @image_view.frame = self.bounds
    end

    image_aspect = @image_view.image.size.width / @image_view.image.size.height
    view_aspect = self.frame.size.width / self.frame.size.height
    NSLog("aspect v: %@ i: %@", view_aspect, image_aspect)
    if (view_aspect - image_aspect).abs < 0.01
      @scroll_view.minimumZoomScale = 1
    else
      @scroll_view.minimumZoomScale = [view_aspect, image_aspect].max
    end

    if self.size.width < self.size.height
      @scroll_view.zoomScale = @image_view.frame.size.width / self.frame.size.width
    else
      @scroll_view.zoomScale = @image_view.frame.size.height / self.frame.size.height
    end


    NSLog("zoom: %@", @scroll_view.minimumZoomScale)

  end

  def add_image_view
    puts "adding image view"
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
