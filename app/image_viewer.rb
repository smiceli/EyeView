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
