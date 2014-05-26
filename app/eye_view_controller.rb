class EyeViewController < UIViewController

  attr_accessor :light_brightness
  
  def loadView
    @camera = BHSCamera.alloc.init
    @image_store = BHSImageStore.new
    self.add_camera_view
    self.add_hud_view
  end

  def add_camera_view
    view = EyeView.alloc.initWithFrame UIScreen.mainScreen.bounds
    view.min_scale = 1.0
    view.max_scale = @camera.max_zoom
    view.delegate = self
    self.add_camera_layer_to(view)
    self.view = view
  end

  def add_hud_view
    hud = EyeViewHud.alloc.initWithFrame self.view.bounds
    hud.delegate = self
    Motion::Layout.new {|layout|
      layout.view self.view
      layout.subviews "HUD" => hud
      layout.vertical "|-0-[HUD]-0-|"
      layout.horizontal "|-0-[HUD]-0-|"
    }
    hud
  end

  def add_camera_layer_to(view)
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
      @camera.orientation = UIApplication.sharedApplication.statusBarOrientation
    end
  end

  def take_picture
    @camera.take_picture do |image|
      if image
        @camera.stop_video
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
    @image_store.store image
    self.show_image_viewer
  end

  def show_image_viewer
    if @image_store.images.count == 0
      alert = UIAlertView.alloc.init
      alert.title = ""
      alert.message = "No images in history yet."
      alert.addButtonWithTitle('OK')
      alert.show
      return
    end

    @image_array_viewer = BHSImageArrayViewController.alloc.initWithTransitionStyle(UIPageViewControllerTransitionStyleScroll, navigationOrientation: UIPageViewControllerNavigationOrientationHorizontal, options: nil)
    @image_array_viewer.image_store = @image_store
    @image_array_viewer.view_delegate = self
    self.presentViewController(@image_array_viewer, animated:false, completion:nil)
  end

  def dismiss_image_viewer
    @camera.start_video
    @image_array_viewer.dismissViewControllerAnimated(false, completion:nil)
  end

  def light_on(is_light_on)
    @camera.light_on = is_light_on
  end

  def light_brightness
    @camera.light_brightness
  end

  def light_brightness=(brightness)
    @camera.light_brightness = brightness
  end

  def zoom(scale)
    @camera.zoom(scale.abs)
  end
end
