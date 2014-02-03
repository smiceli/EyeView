class EyeView < UIView
  attr_accessor :delegate
  attr_accessor :min_scale
  attr_accessor :max_scale

  def initWithFrame(frame)
    if super
      self.backgroundColor = UIColor.redColor
      self.add_zoom_gesture
      self.add_freeze_gesture
    end
    self
  end

  def add_zoom_gesture
    @scale = 1.0
    self.addGestureRecognizer UIPinchGestureRecognizer.alloc.initWithTarget(self, action: :"pinching:")
  end

  def pinching(recognizer)
    scale = @scale * recognizer.scale
    if scale < @min_scale
      scale = @min_scale
    elsif scale > @max_scale
      scale = @max_scale
    end
    if recognizer.state == UIGestureRecognizerStateEnded
      @scale = scale
    end

    if @delegate
      delegate.zoom(scale)
    end
  end

  def add_freeze_gesture
    g = UITapGestureRecognizer.alloc.initWithTarget self, action: :"freeze_picture:"
    g.numberOfTapsRequired = 2
    self.addGestureRecognizer g
  end

  def freeze_picture(recognizer)
    @delegate.take_picture if @delegate
  end
end
