# encoding: utf-8
module NavigationHelper

  def user_top_menu_link(title, url, options = {})
    current_tab = options.delete(:current)
    options[:class] ||= 'inline-block'
    options[:class] << ((current_tab == title) ? ' active' : '')
    content_tag(:div, link_to(I18n.t('users.menu.' + title), url, class: 'inline-block muted-link soft-half epsilon line-height-1-7 white f-weight-600'), options)
  end

  def pro_side_menu_link(title, url, options = {})
    current_tab = options.delete(:current)
    options[:class] ||= 'nowrap rounded--left--double'
    options[:class] << ((current_tab == title) ? ' active bordered--left bordered--top bordered--bottom relative' : '')
    if options[:icon].include?('group') and @structure
      pending_requests = @structure.participation_requests.upcoming.pending.count
      html_title = "<i class='relative #{options[:icon]}'><span style='padding: 3px; top: -8px; right: -8px;' class='rounded--double f-size-9 absolute bg-red white'>#{pending_requests}</span></i>"
      html_title += "<div class='very-soft--top'>#{I18n.t('pro.structures.side_menu.' + title)}</div>"
    else
      html_title = "<i class='#{options[:icon]}'></i><div class='very-soft--top'>#{I18n.t('pro.structures.side_menu.' + title)}</div>"
    end
    content_tag(:li, link_to(html_title.html_safe, url, class: 'side-menu-link block muted-link relative text--center soft-half'), options)
  end

  def pro_submenu_link(title, url, options = {})
    current_tab = options.delete(:current)
    options[:class] ||= ''
    options[:class] << ((current_tab == title) ? ' active' : '')
    content_tag(:li, link_to(title, url, class: 'submenu-link'), options)
  end

  def side_menu_currently_at(tab)
    render partial: 'layouts/pro/side_menu', locals: { current_tab: tab }
  end

  def pro_menu_currently_at(tab)
    render partial: 'layouts/pro/main_nav', locals: { current_tab: tab }
  end

  def user_menu_currently_at(tab)
    render partial: 'layouts/user_top_menu', locals: { current_tab: tab }
  end
end
