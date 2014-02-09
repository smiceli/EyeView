class BHSCamera < NSObject
  attr_reader :max_zoom
  attr_accessor :orientation

  def init
    NSLog("camera initializing")
    self.withSession do
      self.add_input_device
      self.add_output

      @orientation = AVCaptureVideoOrientationPortrait
      @max_zoom = @device.activeFormat().videoMaxZoomFactor if @device

      @session.startRunning if @output
    end
    self
  end

  def withSession
    @session = AVCaptureSession.alloc.init
    if @session
      @session.sessionPreset = AVCaptureSessionPresetHigh
      yield
    end
  end

  def add_input_device
    # TODO: handle errors
    @device = AVCaptureDevice.defaultDeviceWithMediaType AVMediaTypeVideo
    if not @device
      NSLog("no capture device")
      return
    end

    error = Pointer.new('@')
    @input = AVCaptureDeviceInput.deviceInputWithDevice @device, error: error
    if not @input
      NSLog("not input device")
      return
    end

    @session.addInput @input
  end

  def add_output
    return unless @device

    @output = AVCaptureStillImageOutput.alloc.init
    @output.setOutputSettings AVVideoCodecKey => AVVideoCodecJPEG
    @session.addOutput @output
  end

  def fake_picture
    UIImage.imageNamed "picture.jpg"
  end

  def take_picture(&completion_block)

    @picture_completion_block = completion_block

    if not @device
      @image = self.fake_picture
      @picture_completion_block.call @image
      return
    end

    @image = nil
    video_connection = @output.connectionWithMediaType(AVMediaTypeVideo)
    return unless video_connection

    video_connection.videoOrientation = @orientation

    error = Pointer.new('@')
    @output.captureStillImageAsynchronouslyFromConnection video_connection, completionHandler: lambda { |buffer, error|
      imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation buffer
      @image = UIImage.alloc.initWithData imageData
      @picture_completion_block.call @image
    }
  end

  def get_video_layer
    if not @preview_layer
      @preview_layer = AVCaptureVideoPreviewLayer.alloc.initWithSession(@session)
      if @preview_layer
        @preview_layer.videoGravity = AVLayerVideoGravityResizeAspectFill
        @preview_layer.connection.videoOrientation = @orientation if @preview_layer.connection
      end
    end
    @preview_layer
  end

  def orientation=(orientation)
    video_layer = self.get_video_layer
    connection = video_layer.connection if video_layer
    connection.videoOrientation = orientation if connection
    @orientation = orientation
  end

  def with_locked_config
    error = Pointer.new('@')
    if @device and @device.lockForConfiguration error
      yield
      @device.unlockForConfiguration 
    end
  end

  def toggle_light
    self.with_locked_config do
      if @device.hasTorch
        @device.torchMode = self.negate_light_setting @device.torchMode
      end
    end
  end

  def negate_light_setting(torch_mode)
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
