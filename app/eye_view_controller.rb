class EyeViewController < UIViewController
  def loadView
    @camera = BHSCamera.alloc.init
    self.view = self.camera_view
    self.view.addSubview self.hud_view
  end

  def camera_view
    puts 'view'
    view = EyeView.alloc.initWithFrame UIScreen.mainScreen.bounds
    view.min_scale = 1.0
    view.max_scale = @camera.max_zoom
    view.delegate = self
    self.add_camera_layer_to(view)
    view
  end

  def hud_view
    puts 'hud'
    hud = EyeViewHud.alloc.initWithFrame self.view.bounds
    hud.delegate = self
    hud
  end

  def add_camera_layer_to(view)
    puts 'layer'
    @camera_layer = @camera.get_video_layer
    if @camera_layer
      @camera_layer.frame = view.bounds;
    end
    view.layer.addSublayer @camera_layer
    @camera_layer
  end

  def viewWillLayoutSubviews
    if @camera_layer
      @camera_layer.frame = self.view.bounds
    end
  end

  def take_picture
    NSLog "___________________________"
    image = @camera.take_picture do |image|
      if image
        show_picture(image)
      else
        alert = UIAlertView.alloc.init
        alert.title = "Error"
        alert.message = "Can't capture picture"
        alert.addButtonWithTitle('OK')
        alert.show
      end
    end
  end

  def show_picture(image)
    @image_view = BHSImageViewer.alloc.init
    @image_view.image = image
    @image_view.delegate = self
    Motion::Layout.new do |layout|
      layout.view self.view
      layout.subviews "image" => @image_view
      layout.vertical "|[image]|"
      layout.horizontal "|[image]|"
    end
  end

  def dismiss_image_viewer
    @image_view.removeFromSuperview
  end

  def light_tapped
    @camera.toggle_light
  end

  def zoom(scale)
    @camera.zoom(scale.abs)
  end
end
