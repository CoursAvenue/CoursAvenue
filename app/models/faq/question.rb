class Faq::Question < ActiveRecord::Base
  acts_as_paranoid

  validates :question, presence: true
  validates :answer  , presence: true

  has_one :faq_section
end
