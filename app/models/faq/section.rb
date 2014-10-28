class Faq::Section < ActiveRecord::Base
  acts_as_paranoid

  validates :title, presence: true

  has_many :questions, class_name: 'Faq::Question', foreign_key: 'faq_section_id'
  accepts_nested_attributes_for :questions
end
