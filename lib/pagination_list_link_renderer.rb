# See blogpost: http://thewebfellas.com/blog/2010/8/22/revisited-roll-your-own-pagination-links-with-will_paginate-and-rails-3
class PaginationListLinkRenderer < WillPaginate::ActionView::LinkRenderer

  protected

    def page_number(page)
      unless page == current_page
        tag(:li, link(page, page, rel: rel_value(page)), class: 'btn btn--sml')
      else
        tag(:li, link(page, '#'), class: 'current btn btn--sml btn--active')
      end
    end

    def previous_or_next_page(page, text, classname)
      if classname == 'previous_page'
        text = '<i class="icon-arrow-left"></i>' + text
      else
        text = text + '<i class="icon-arrow-right"></i>'
      end

      if page
        tag(:li, link(text, page), class: classname + ' btn btn--sml')
      else
        tag(:li, text, class: classname + ' disabled btn btn--sml')
      end
    end

    def gap
      tag :li, link(super, '#'), class: 'disabled btn btn--sml'
    end

    def html_container(html)
      tag(:ul, html, container_attributes)
    end

end
