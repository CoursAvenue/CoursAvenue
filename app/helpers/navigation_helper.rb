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
    options[:class] ||= 'nowrap'
    options[:class] << ((current_tab == title) ? ' active' : '')
    if options[:icon].present?
      html_title = "<i class='#{options[:icon]}'></i> #{I18n.t('pro.structures.side_menu.' + title)}".html_safe
    end
    if options.has_key? :completed
      if options[:completed]
        html_title << "<i class='fa absolute east fa-check soft--right completion-icon #{(current_tab == title ? ' white' : 'green')}'></i>".html_safe
      else
        html_title << "<i class='fa absolute east fa-plus soft--right completion-icon #{(current_tab == title ? ' white' : 'orange')}'></i>".html_safe
      end
    end
    content_tag(:li, link_to(html_title, url, class: 'side-menu-link relative'), options)
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
