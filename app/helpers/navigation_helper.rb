# encoding: utf-8
module NavigationHelper
  def pro_breadcrumb_menu_link(title, url, options = {})
    current_tab = options.delete(:current)
    options[:class] ||= ''
    options[:class] << ' flexbox__item text--center one-fifth'
    link = link_to url, class: "step-breadcrumb--item #{((current_tab == title) ? ' active' : '')}" do
      case title
      when 'Infos générales'
        "Etape 1/5 : infos générales
        <br>
        <i class='milli'>Temps estimé : 4min</i>".html_safe
      when 'Mes professeurs'
        "Etape 2/5 : profs
        <br>
        <i class='milli'>Temps estimé : 1min</i>".html_safe
      when "Lieux d'enseignements"
        "Etape 3/5 : lieu
        <br>
        <i class='milli'>Temps estimé : 2min</i>".html_safe
      when 'Mes cours'
        "Etape 4/5 : cours
        <br>
        <i class='milli'>Temps estimé : 7min</i>".html_safe
      when 'Validation'
        "Etape 5/5 : validation
        <br>
        <i class='milli'>Temps estimé : 1min</i>".html_safe
      end
    end
    content_tag(:li, link, options)
  end

  def pro_side_menu_link(title, url, options = {})
    current_tab = options.delete(:current)
    options[:class] ||= ''
    options[:class] << ((current_tab == title) ? ' active' : '')
    content_tag(:li, link_to(title, url, class: 'side-menu-link'), options)
  end

  def pro_submenu_link(title, url, options = {})
    current_tab = options.delete(:current)
    options[:class] ||= ''
    options[:class] << ((current_tab == title) ? ' active' : '')
    content_tag(:li, link_to(title, url, class: 'submenu-link'), options)
  end

  def side_menu_currently_at(tab)
    render partial: 'layouts/pro/side_menu', locals: {current_tab: tab}
    # render partial: 'layouts/pro/breadcrumb', locals: {current_tab: tab}
  end

  def menu_currently_at(tab)
    render partial: 'layouts/pro/main_nav', locals: {current_tab: tab}
  end
end
