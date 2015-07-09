class Guide < ActiveRecord::Base
  extend FriendlyId
  friendly_id :title, use: [:slugged, :finders]

  attr_accessible :title, :description, :questions_attributes

  has_many :questions, class_name: 'Guide::Question', dependent: :destroy
  has_many :answers,   class_name: 'Guide::Answer', through: :questions

  validates :title,       presence: true
  validates :description, presence: true

  accepts_nested_attributes_for :questions,
                                reject_if: :reject_question,
                                allow_destroy: true

  # The subjects associated with different answers of this guide.
  #
  # @return An array of subjects.
  def subjects
    answers.flat_map(&:subjects).uniq
  end

  private

  # Method to check if we reject the question.
  #
  # We reject the question if the content is empty and the questions doesn't already exists.
  # If the question exists and the content is empty, we add the attribute to delete the question.
  #
  # @return Boolean
  def reject_question(attributes)
    exists = attributes[:id].present?
    if exists and attributes[:content].blank?
      attributes.merge!({ :_destroy => 1 })
    end

    return (!exists and attributes[:content].blank?)
  end
end
