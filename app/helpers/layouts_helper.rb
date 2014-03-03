module LayoutsHelper
  def active_page(page)
    'active' if current_page?(page)
  end

  def active_controller(controller)
    'active' if controller_name == controller
  end
end
