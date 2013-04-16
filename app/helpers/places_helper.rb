module PlacesHelper
  def short_address(place)
    "#{place.city.name}"
  end

  def readable_address(place)
    address = ""
    address << content_tag(:span, itemprop: 'address', itemscope: true, itemtype: 'http://schema.org/PostalAddress') do
      inner_address = ''
      inner_address << content_tag(:span, place.street, itemprop: 'streetAddress')
      inner_address << ', '
      inner_address << content_tag(:span, place.city.name, itemprop: 'addressLocality')
      inner_address.html_safe
    end
    address.html_safe
  end
end
