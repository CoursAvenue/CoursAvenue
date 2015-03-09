class Newsletter::MailingList < ActiveRecord::Base
  belongs_to :newsletter
end
