class NewsletterBlocSerializer < ActiveModel::Serializer
  attributes :id, :position, :type, :content, :image, :view_type, :sub_blocs

  def image
    object.image.url
  end

  def view_type
    object.type.split('::').last.downcase
  end

  def sub_blocs
    object.type == 'Newsletter::Bloc::Multi' ? object.sub_blocs : []
  end
end
