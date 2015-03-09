class Newsletter::Subscription < ActiveRecord::Base
  belongs_to :newsletter_mailing_list
  belongs_to :user_profile
end
