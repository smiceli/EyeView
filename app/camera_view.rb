class CameraView < UIView
  attr_accessor :delegate
  attr_accessor :min_scale
  attr_accessor :max_scale

  def initWithFrame(frame)
    if super
      self.backgroundColor = UIColor.blackColor
      self.add_zoom_gestures
      self.add_freeze_gesture
    end
    self
  end

  def add_zoom_gestures
    @scale = 1.0
    self.addGestureRecognizer UIPinchGestureRecognizer.alloc.initWithTarget(self, action: :"pinching:")
    self.addGestureRecognizer UIPanGestureRecognizer.alloc.initWithTarget(self, action: :"panning:")
  end

  def pinching(recognizer)
    scale = self.adjust_scale(@scale * recognizer.scale, recognizer)
  end

  def panning(recognizer)
    delta = recognizer.translationInView self
    velocity = recognizer.velocityInView self
    return if (delta.x.abs >= delta.y.abs)

    inc = delta.y/20.0 * -1 #velocity.y/80.0
    scale = self.adjust_scale(@scale + inc, recognizer)
    NSLog("s: %@ i: %@ (%@, %@)", scale, inc,  delta.x, delta.y)
  end

  def adjust_scale(scale, recognizer)
    scale = scale.clamp(@min_scale, @max_scale)
    @scale = scale if recognizer.state == UIGestureRecognizerStateEnded
    delegate.zoom(scale) if @delegate
    scale
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
