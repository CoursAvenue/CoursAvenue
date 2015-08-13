class AdminDecorator < Draper::Decorator

  def avatar(size=60)
    if object.structure.logo.present?
      h.image_tag object.structure.logo.url(:thumb), class: 'rounded--circle block center-block bordered', width: size, height: size
    else
      h.content_tag('div', '', class: "comment-avatar-#{size}")
    end
  end
end
