class NewsletterSerializer < ActiveModel::Serializer

  attributes :id, :title, :state, :email_object, :sender_name, :reply_to, :layout_id, :blocs,
             :newsletter_mailing_list_id, :structure_id

  has_many :blocs, serializer: NewsletterBlocSerializer
end
