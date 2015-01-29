class PlaceDecorator < Draper::Decorator

  def popover_place_infos
    infos = ""
    if place.info.present?
      infos << "<div><strong>Infos publiques</strong><br>#{place.info}</div>"
    end
    if place.private_info.present?
      infos << "<div><strong>Infos privées</strong><br>#{place.private_info}</div>"
    end
    infos.html_safe
  end
end
