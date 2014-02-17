class BHSImageViewerController < UIViewController
  attr_accessor :delegate
  attr_accessor :image
  attr_accessor :index

  def init
    if super
      @image_view = BHSImageViewer.alloc.init
      @image_view.image = image
      @image_view.delegate = self

      self.view = @image_view
    end
    self
  end

  def image=(image)
    @image_view.image = image
  end

  def delegate=(delegate)
    @image_view.delegate = delegate
  end
end
