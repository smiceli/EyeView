class BHSCamera < NSObject
  attr_reader :max_zoom

  def init
    NSLog("camera initializing")
    self.withSession do
      self.add_input_device
      self.add_output
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
    error = Pointer.new('@')
    if @device
      @input = AVCaptureDeviceInput.deviceInputWithDevice @device, error: error
      if @input
        @session.addInput @input
      end
    end
  end

  def add_output
    if @device
      @output = AVCaptureStillImageOutput.alloc.init
      @output.setOutputSettings AVVideoCodecKey => AVVideoCodecJPEG
      @session.addOutput @output
    end
  end

  def take_picture(&completion_block)
    NSLog "taking picture 1"
    return unless @device

    NSLog "taking picture 2"

    @image = nil
    @picture_completion_block = completion_block
    video_connection = @output.connectionWithMediaType(AVMediaTypeVideo)

    if video_connection
      NSLog "found connection"
      error = Pointer.new('@')
      @output.captureStillImageAsynchronouslyFromConnection video_connection, completionHandler: lambda { |buffer, error|
        imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation buffer
        @image = UIImage.alloc.initWithData imageData
        @picture_completion_block.call @image
      }
    end
  end

  def connection_with(media_type)
    connection = nil
    NSLog "loocing for video connection"
    @output.connections.each do |c|
      NSLog "connection %@", c
      c.inputPorts do |port|
        NSLog "port %@", port
        if port.mediaType.isEqual media_type
          connection = c
        end
      end
    end
    connection
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
