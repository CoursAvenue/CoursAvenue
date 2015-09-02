class PlaceDecorator < Draper::Decorator
  delegate_all

  def popover_place_infos(show_private_info=false)
    infos = ""
    if info.present?
      infos << "<div><strong>Infos publiques</strong><br>#{info}</div>"
    end
    if show_private_info and private_info.present?
      infos << "<div><strong>Infos privées</strong><br>#{private_info}</div>"
    end
    infos.html_safe
  end
end
