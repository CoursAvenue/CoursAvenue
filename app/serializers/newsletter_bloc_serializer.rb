class NewsletterBlocSerializer < ActiveModel::Serializer
  attributes :id, :position, :type, :content, :image, :view_type

  def image
    object.image.url
  end

  def view_type
    object.type.split('::').last.downcase
  end
end
