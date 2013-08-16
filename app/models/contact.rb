class Contact < ActiveRecord::Base
  acts_as_paranoid

  attr_accessible :name, :phone, :mobile_phone, :email

  belongs_to :commentable, polymorphic: true
end
