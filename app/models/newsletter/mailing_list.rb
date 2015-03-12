class Newsletter::MailingList < ActiveRecord::Base
  attr_accessible :name, :tag, :filters

  belongs_to :newsletter
  belongs_to :structure

  has_many :user_profiles

  validates :name, presence: true
  validates :tag, presence: true

  store_accessor :metadata, :filters

end
