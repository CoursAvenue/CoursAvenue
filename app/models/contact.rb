class Contact < ActiveRecord::Base
  acts_as_paranoid

  attr_accessible :name, :phone, :mobile_phone, :email

  validates  :name, presence: true

  belongs_to :commentable, polymorphic: true
end
