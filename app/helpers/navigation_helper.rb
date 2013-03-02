module NavigationHelper

  def pro_side_menu_link(title, url, options = {})
    current_tab = options.delete(:current)
    options[:class] = (current_tab == title) ? 'active' : ''
    content_tag(:li, link_to(title, url, class: 'side-menu-link'), options)
  end

  def pro_submenu_link(title, url, options = {})
    current_tab = options.delete(:current)
    options[:class] = (current_tab == title) ? 'active' : ''
    content_tag(:li, link_to(title, url, class: 'submenu-link'), options)
  end

  def side_menu_currently_at(tab)
    render partial: 'layouts/pro/side_menu', locals: {current_tab: tab}
  end

  def menu_currently_at(tab)
    render partial: 'layouts/pro/main_nav', locals: {current_tab: tab}
  end
end
