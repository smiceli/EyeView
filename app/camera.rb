class BHSCamera < NSObject
  def init
    NSLog("camera initializing")
    @session = AVCaptureSession.alloc.init
    if @session
      @session.sessionPreset = AVCaptureSessionPresetHigh

      @device = AVCaptureDevice.defaultDeviceWithMediaType AVMediaTypeVideo
      error = Pointer.new('@')
      @input = AVCaptureDeviceInput.deviceInputWithDevice @device, error: error

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
    NSLog("with_locked_config 1")
    if @device.lockForConfiguration error
      NSLog("with_locked_config 2")
      yield
      @device.unlockForConfiguration 
    end
  end

  def toggle_light
    NSLog("toggle_light")
    if @device.hasTorch
      self.with_locked_config do
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
