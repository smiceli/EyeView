class BHSImageViewer < UIView
  attr_accessor :delegate
  attr_accessor :image

  def initWithFrame(frame)
    if super
      self.add_image_view
      self.add_double_tap_gesture
    end
    self
  end

  def add_image_view
    @image_view = UIImageView.alloc.init
    Motion::Layout.new do |layout|
      layout.view self
      layout.subviews "image" => @image_view
      layout.vertical "|[image]|"
      layout.horizontal "|[image]|"
    end
  end

  def image=(image)
    @image_view.image = image
  end

  def add_double_tap_gesture
    g = UITapGestureRecognizer.alloc.initWithTarget self, action: :"double_tapped:"
    g.numberOfTapsRequired = 2
    self.addGestureRecognizer g
  end

  def double_tapped(recognizer)
    @delegate.dismiss_image_viewer if @delegate
  end
end
