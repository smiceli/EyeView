class BHSFakeCamera < NSObject
  attr_reader :max_zoom
  attr_accessor :orientation
  attr_accessor :light_on
  attr_accessor :light_brightness

  def init
    NSLog("fake camera initializing")
    @max_zoom = 10.0
    @light_brightness = 1.0
    self
  end

  def take_picture(&completion_block)
    @image = UIImage.imageNamed "picture.jpg"
    completion_block.call @image
  end

  def zoom(zoom)
  end

  def get_video_layer
  end

  def start_video
  end

  def stop_video
  end

end
