class BHSImageArrayViewController < UIPageViewController
  attr_accessor :image_store
  attr_accessor :view_delegate

  def initWithTransitionStyle(style, navigationOrientation:navigationOrientation,  options:options)
    if super
      self.dataSource = self
    end
    super
  end

  def viewWillAppear(animated)
    super
    vc = self.controller_for_image 0
    self.setViewControllers([vc], direction:UIPageViewControllerNavigationDirectionForward, animated:false, completion:nil)
  end

  def controller_for_image(index)
    vc = nil
    if index >= 0 and index < @image_store.images.count
      vc = BHSImageViewerController.alloc.init
      vc.index = index
      vc.delegate = @view_delegate
      vc.image = @image_store.images[index]
    end
    vc
  end

  def pageViewController(pageViewController, viewControllerAfterViewController:viewController)
    self.controller_for_image viewController.index + 1
  end

  def pageViewController(pageViewController, viewControllerBeforeViewController:viewController)
    self.controller_for_image viewController.index - 1
  end
end
