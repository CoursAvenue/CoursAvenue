module NavigationHelper

  def submenu_link(title, url, options = {})
    current_tab = options.delete(:current)
    options[:class] = (current_tab == title) ? 'active' : ''
    content_tag(:li, link_to(title, url, class: 'submenu-link'), options)
  end

  def currently_at(tab)
    render partial: 'layouts/pro/main_nav', locals: {current_tab: tab}
  end
end
