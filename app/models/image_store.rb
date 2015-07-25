class BHSImageStore
  attr_reader :images

  def initialize
    @images = []
  end

  def store(image)
    if @images.count >= 10
      @images.pop
    end
    @images.unshift image
  end
end
