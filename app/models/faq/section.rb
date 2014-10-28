class Faq::Section < ActiveRecord::Base
  acts_as_paranoid

  validates :title, presence: true
end
