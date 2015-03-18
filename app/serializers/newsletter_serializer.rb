class NewsletterSerializer < ActiveModel::Serializer
  attributes :title, :state, :object, :sender_name, :reply_to, :layout_id, :blocs
  has_many :blocs, serializer: NewsletterBlocSerializer
end
