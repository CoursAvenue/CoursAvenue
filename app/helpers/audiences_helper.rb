module AudiencesHelper

  def join_audiences(audiences)
    audiences.map{ |audience| t(audience.name) }.join(', ')
  end

  def join_audiences_list(levels)
    content_tag :ul, class: 'nav' do
      audiences.order(:order).collect do |audience|
        content_tag(:li, t(audience.name))
      end.join(', ').html_safe
    end
  end
end
