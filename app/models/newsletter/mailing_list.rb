class Newsletter::MailingList < ActiveRecord::Base
  belongs_to :newsletter

  has_many :subscriptions, class_name: 'Newsletter::Subscription'
end
