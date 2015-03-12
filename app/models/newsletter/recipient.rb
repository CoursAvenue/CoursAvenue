class Newsletter::Recipient < ActiveRecord::Base
  belongs_to :user_profile
  belongs_to :newsletter
end
