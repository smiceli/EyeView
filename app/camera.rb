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

      self.start_video
    end
    self
  end

  def withSession
    @session = AVCaptureSession.alloc.init
    if @session
      @session.sessionPreset = AVCaptureSessionPresetPhoto
      yield
    end
  end

  def add_input_device
    # TODO: handle errors
    @device = AVCaptureDevice.defaultDeviceWithMediaType AVMediaTypeVideo
    unless @device
      NSLog("no capture device")
      return
    end

    error = Pointer.new('@')
    @input = AVCaptureDeviceInput.deviceInputWithDevice @device, error: error
    unless @input
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

  def start_video
      @session.startRunning if @output
  end

  def stop_video
      @session.stopRunning if @output
  end

  def take_fake_picture(completion_block)
      @image = UIImage.imageNamed "picture.jpg"
      completion_block.call @image
  end

  def take_picture(&completion_block)
    @image = nil
    return take_fake_picture completion_block unless @device

    video_connection = @output.connectionWithMediaType(AVMediaTypeVideo)
    return unless video_connection

    video_connection.videoOrientation = @orientation
    self.take_picture_using_connection video_connection, completion_block
  end

  def take_picture_using_connection(video_connection, completion_block)
    error = Pointer.new('@')
    @output.captureStillImageAsynchronouslyFromConnection(video_connection, completionHandler:
      lambda { |buffer, error|
        imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation buffer
        @image = UIImage.alloc.initWithData imageData
        completion_block.call @image
      }
    )
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
      zoom = @max_zooa
    end
    zoom
  end
end
