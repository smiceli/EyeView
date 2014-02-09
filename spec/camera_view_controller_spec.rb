describe "Eye View Controller" do
  tests EyeViewController

  it "has one camera iew" do
    views(EyeView).size.should.equal 1
  end

  it "has one HUD" do
    views(EyeViewHud).size.should.equal 1
  end

  def equal_to_rect(r2)
    lambda { |r1| CGRectEqualToRect(r1, r2) }
  end

  it "should show image view full screen when double tapped" do
    tap controller.view, :times => 2
    image_viewers = views BHSImageViewer
    image_viewers.size.should.equal 1
    image_viewers[0].frame.should.be equal_to_rect controller.view.bounds
  end

  it "should rotate image view" do
    tap controller.view, :times => 2
    rotate_device :to => :landscape
    image_viewers = views BHSImageViewer
    image_viewers[0].frame.should.be equal_to_rect controller.view.bounds
  end

end