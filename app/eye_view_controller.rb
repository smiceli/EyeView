class EyeViewController < UIViewController
  def loadView
    @camera = BHSCamera.alloc.init
    self.view = EyeView.alloc.initWithFrame UIScreen.mainScreen.bounds
    self.add_camera_layer

    hud = EyeViewHud.alloc.initWithFrame self.view.bounds
    hud.delegate = self
    self.view.addSubview hud
  end

  def add_camera_layer
    @camera_layer = @camera.get_video_layer
    if @camera_layer
      @camera_layer.frame = self.view.bounds;
      self.view.layer.addSublayer @camera_layer
    end
  end

  def viewWillLayoutSubviews
    if @camera_layer
      @camera_layer.frame = self.view.bounds
    end
  end

  def light_tapped
    puts "~~~~~~~~~~~~ light tapped"
    @camera.toggle_light
  end
end
