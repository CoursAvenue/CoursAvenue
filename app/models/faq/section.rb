class Faq::Section < ActiveRecord::Base
  extend FriendlyId
  acts_as_paranoid

  friendly_id :title, use: [:slugged, :finders]
  attr_accessible :title, :slug, :questions, :questions_attributes

  has_many :questions, class_name: 'Faq::Question', foreign_key: 'faq_section_id', dependent: :destroy
  accepts_nested_attributes_for :questions, reject_if: :reject_question, allow_destroy: true

  validates :title, presence: true

  # Check if we should reject the Faq::Question.
  # We reject if the question is blank.
  #
  # @return a Boolean.
  def reject_question(attributes)
    exists = attributes[:id].present?
    blank = attributes[:question].blank?

    if blank and exists
      attributes.merge!({:_destroy => 1})
    end

    (blank and !exists)
  end
end
