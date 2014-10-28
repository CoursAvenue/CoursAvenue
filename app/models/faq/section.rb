class Faq::Section < ActiveRecord::Base
  acts_as_paranoid

  attr_accessible :title, :questions, :questions_attributes

  has_many :questions, class_name: 'Faq::Question', foreign_key: 'faq_section_id'
  accepts_nested_attributes_for :questions, reject_if: :reject_question, allow_destroy: true

  validates :title, presence: true

  # Check if we should reject the Faq::Question.
  # We reject if the question is blank.
  #
  # @return a Boolean.
  def reject_question(attributes)
    blank = attributes[:question].blank?

    if blank
      attributes.merge!({:_destroy => 1 })
    end

    blank
  end
end
