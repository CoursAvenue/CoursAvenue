class Newsletter::MailingList < ActiveRecord::Base
  belongs_to :newsletter
  belongs_to :structure

  has_many :user_profiles

  validates :name, presence: true
  validates :tag, presence: true
end
