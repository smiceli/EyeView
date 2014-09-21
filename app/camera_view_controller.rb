class CameraViewController < UIViewController

  attr_accessor :light_brightness
  
  def loadView
    @image_store = BHSImageStore.new
    self.add_camera
    self.add_camera_control_view
  end

  def add_camera
    @camera = BHSCamera.alloc.init
    if (!@camera.has_camera?)
      @camera = BHSFakeCamera.alloc.init
    end
  end

  def add_camera_control_view
    @camera_control = CameraControlView.alloc.init_with_camera(@camera, UIScreen.mainScreen.bounds)
    @camera_control.delegate = self
    self.view = @camera_control
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
