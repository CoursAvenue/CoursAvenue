class Newsletter::MailingList < ActiveRecord::Base
  belongs_to :newsletter
  belongs_to :structure

  validates :name, presence: true
  validates :tag, presence: true
end
