class UIView
  def constrain_to_view(view)
    Motion::Layout.new {|layout|
      layout.view view
      layout.subviews "self" => self
      layout.vertical "|-0-[self]-0-|"
      layout.horizontal "|-0-[self]-0-|"
    }
  end
end
