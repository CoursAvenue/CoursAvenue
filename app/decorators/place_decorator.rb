class PlaceDecorator < Draper::Decorator
  delegate_all

  def popover_place_infos
    infos = ""
    if info.present?
      infos << "<div><strong>Infos publiques</strong><br>#{info}</div>"
    end
    if private_info.present?
      infos << "<div><strong>Infos privées</strong><br>#{private_info}</div>"
    end
    infos.html_safe
  end
end
