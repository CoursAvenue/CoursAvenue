class MetroLineDecorator < Draper::Decorator
  delegate_all

  def chip
    _chip = ''
    if bis?
      _chip += <<-eos
        <div class="metro-line metro-line--bis #{line_class_name}">
          <span class="v-middle"> #{number_without_bis}</span><span class="metro-line__bis">bis</span>
        </div>
      eos
    else
      _chip += "<div class=\"metro-line #{line_class_name}\">#{number}</div>"
    end
    _chip.html_safe
  end

  def line_class_name
    "metro-line-#{number.downcase.gsub(' ', '-')}"
  end

end
