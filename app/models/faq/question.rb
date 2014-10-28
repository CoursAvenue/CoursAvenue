class Faq::Question < ActiveRecord::Base
  acts_as_paranoid

  attr_accessible :question, :answer

  has_one :section, class_name: 'Faq::Section'

  validates :question, presence: true
  validates :answer  , presence: true
end
