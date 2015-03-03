module LevelsHelper

  def join_levels(levels)
    return I18n.t('level.all') if levels.empty?
    levels.map{ |level| I18n.t(level.name) }.join(', ')
  end

  def join_levels_list(levels)
    content_tag :ul, class: 'nav' do
      levels.order(:order).collect do |level|
        content_tag(:li, I18n.t(level.name))
      end.join(', ').html_safe
    end
  end

end
