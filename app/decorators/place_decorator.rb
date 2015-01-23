class PlaceDecorator < Draper::Decorator

  def popover_place_infos
    infos = ""
    if place.info.present?
      infos << "<div>#{place.info}</div>"
    end
    if place.private_info.present?
      infos << "<div>#{place.private_info}</div>"
    end
    infos.html_safe
  end
end
