class NewsletterBlocSerializer < ActiveModel::Serializer
  attributes :id, :position, :type, :content, :image, :view_type

  def image
    object.image.url
  end

  def view_type
    object.type == 'Newsletter::Bloc::Text' ? 'text' : 'image'
  end
end
