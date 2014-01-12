class BHSCamera < NSObject
  attr_reader :max_zoom

  def init
    NSLog("camera initializing")
    @session = AVCaptureSession.alloc.init
    if @session
      @session.sessionPreset = AVCaptureSessionPresetHigh

      @device = AVCaptureDevice.defaultDeviceWithMediaType AVMediaTypeVideo
      error = Pointer.new('@')
      if @device
        @input = AVCaptureDeviceInput.deviceInputWithDevice @device, error: error
        @max_zoom = @device.activeFormat().videoMaxZoomFactor
      end

      if @input
        @session.addInput @input
        @session.startRunning
      end
    end
    self
  end

  def get_video_layer
    previewLayer = AVCaptureVideoPreviewLayer.alloc.initWithSession(@session)
    if previewLayer
      previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
    end
    previewLayer
  end

  def with_locked_config
    error = Pointer.new('@')
    NSLog("with_locked_config %@", @device)
    if @device and @device.lockForConfiguration error
      yield
      @device.unlockForConfiguration 
    end
  end

  def toggle_light
    NSLog("toggle_light")
    self.with_locked_config do
      if @device.hasTorch
        NSLog("toggle_light 2")
        @device.torchMode = self.negate_light_setting @device.torchMode
      end
    end
  end

  def negate_light_setting(torch_mode)
    NSLog("negate")
    if torch_mode == AVCaptureTorchModeOn
      AVCaptureTorchModeOff
    else
      AVCaptureTorchModeOn
    end
  end

  def zoom(zoom)
    zoom = cap_zoom(zoom)
    self.with_locked_config do
      @device.videoZoomFactor = zoom
    end
  end

  def cap_zoom(zoom)
    if zoom < 1.0
      zoom = 1.0
    elsif zoom > @max_zoom
      zoom = @max_zoom
    end
    zoom
  end

  def get_back_camera
    devices = AVCaptureDevice.devices
    NSLog("getting devices")
    devices.each {|d|
      NSLog("%@", d.localizedName)
      if d.hasMediaType AVMediaTypeVideo
        NSLog("has video")
      end
    }
  end
end
