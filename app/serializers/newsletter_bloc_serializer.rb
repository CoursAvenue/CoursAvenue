class NewsletterBlocSerializer < ActiveModel::Serializer
  attributes :id, :position, :type, :content, :image
end
