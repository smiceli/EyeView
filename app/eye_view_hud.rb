class EyeViewHud < UIView
  attr_accessor :delegate

  def initWithFrame(frame)
    if super
      self.add_history_button
      self.add_light_button
      self.add_light_adjust_gesture
    end
    self
  end

  def add_history_button
    @history_button = UIButton.alloc.init
    @history_button.setTitle("🕑 ", forState:UIControlStateNormal)
    @history_button.layer.borderColor = UIColor.whiteColor.CGColor
    @history_button.layer.borderWidth = 1
    @history_button.layer.cornerRadius = 8
    @history_button.alpha = 0.5
    @history_button.addTarget self, action: :'history_tapped', forControlEvents:UIControlEventTouchUpInside

    Motion::Layout.new {|layout|
      layout.view self
      layout.subviews "history" => @history_button
      layout.vertical "[history(40)]-|"
      layout.horizontal "|-[history(40)]"
    }
  end

  def history_tapped
    @delegate.show_image_viewer if @delegate
  end

  def add_light_button
    @light_button = UIButton.alloc.init
    @light_button.setTitle("💡", forState:UIControlStateNormal)
    @light_button.layer.borderColor = UIColor.whiteColor.CGColor
    @light_button.layer.borderWidth = 1
    @light_button.layer.cornerRadius = 8
    @light_button.alpha = 0.5
    @light_button.addTarget self, action: :'light_tapped', forControlEvents:UIControlEventTouchUpInside

    Motion::Layout.new {|layout|
      layout.view self
      layout.subviews "light" => @light_button
      layout.vertical "[light(40)]-|"
      layout.horizontal "[light(40)]-|"
    }
  end

  def add_light_adjust_gesture
    g = UILongPressGestureRecognizer.alloc.initWithTarget self, action: :"adjust_light_brightness:"
    @light_button.addGestureRecognizer g
  end

  def light_tapped
    if @brightness_slider_showing
      @brightness_slider.removeFromSuperview
      @brightness_slider_showing = false
    end

    @is_light_on = !@is_light_on
    delegate.light_on(@is_light_on) if delegate
  end

  def adjust_light_brightness recognizer
    return if @brightness_slider_showing
    self.show_light_brightness_slider if recognizer.state == UIGestureRecognizerStateBegan
  end

  def show_light_brightness_slider
    @delegate.light_on(true) if @delegate
    @is_light_on = true
    @brightness_slider_showing = true

    @brightness_slider = UISlider.alloc.init
    @brightness_slider.value = @delegate.light_brightness if @delegate
    @brightness_slider.continuous = true
    @brightness_slider.addTarget self, action: :"brightness_change:", forControlEvents:UIControlEventValueChanged

    Motion::Layout.new {|layout|
      layout.view self
      layout.subviews "light" => @light_button, "slider" => @brightness_slider
      layout.vertical "[slider(==light)]"
      layout.horizontal "[slider(100)]-0-[light]"
    }

    self.addSubview(@brightness_slider)
  end

  def brightness_change(sender)
    @delegate.light_brightness = sender.value if @delegate
  end

end
