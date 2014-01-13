class EyeViewHud < UIView
  attr_accessor :delegate

  def initWithFrame(frame)
    if super
      self.add_light_button
      self.add_picture_button
    end
    self
  end

  def add_light_button
    @light_button = UIButton.alloc.init
    @light_button.backgroundColor = UIColor.yellowColor
    @light_button.addTarget self, action:'light_tapped', forControlEvents:UIControlEventTouchUpInside

    Motion::Layout.new {|layout|
      layout.view self
      layout.subviews "light" => @light_button
      layout.vertical "|-(>=20)-[light(40)]-20-|"
      layout.horizontal "|-(>=20)-[light(40)]-20-|"
    }
  end

  def add_picture_button
    @picture_button = UIButton.alloc.init
    @picture_button.backgroundColor = UIColor.greenColor
    @picture_button.addTarget self, action:'picture_tapped', forControlEvents:UIControlEventTouchUpInside

    Motion::Layout.new {|layout|
      layout.view self
      layout.subviews "picture" => @picture_button
      layout.vertical "|-(>=20)-[picture(40)]-20-|"
      layout.horizontal "|-20-[picture(40)]-(>=20)-|"
    }
  end

  def light_tapped
    delegate.light_tapped if delegate
  end

  def picture_tapped
    delegate.take_picture if delegate
  end
end
