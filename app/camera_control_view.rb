class CameraControlView < UIView

  attr_accessor :delegate

  alias :'super_initWithFrame:' :'initWithFrame:'

  def init_with_camera(camera, frame)
    if super_initWithFrame(frame)
      @camera = camera
      self.init_view
    end
    self
  end

  def init_view
    self.add_sub_views
  end

  def add_sub_views
    self.add_camera_view
    self.add_hud_view
  end

  def add_camera_view
    @camera_view = EyeView.alloc.initWithFrame UIScreen.mainScreen.bounds
    @camera_view.min_scale = 1.0
    @camera_view.max_scale = @camera.max_zoom
    self.add_camera_layer_to(@camera_view)
    @camera_view.constrain_to_view(self)
  end

  def add_hud_view
    @hud = EyeViewHud.alloc.initWithFrame self.bounds
    @hud.constrain_to_view(@camera_view)
  end

  def delegate=(delegate)
    @delegate = delegate
    @hud.delegate = delegate
    @camera_view.delegate = delegate
  end

  def add_camera_layer_to(view)
    @camera_layer = @camera.get_video_layer
    if @camera_layer
      @camera_layer.frame = view.bounds;
      view.layer.addSublayer @camera_layer
    end
  end

  def layoutSubviews
    self.adjust_camera_orientation
  end

  def adjust_camera_orientation
    if @camera_layer
      @camera_layer.frame = self.bounds
      @camera.orientation = UIApplication.sharedApplication.statusBarOrientation
    end
  end

end
