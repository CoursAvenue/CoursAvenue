class Guide::Question < ActiveRecord::Base
  attr_accessible :content, :ponderation, :answers_attributes

  belongs_to :guide
  has_many :answers, class_name: 'Guide::Answer', foreign_key: 'guide_question_id'

  validates :content, presence: true
  validates :ponderation, presence: true
  validates :position, presence: true

  accepts_nested_attributes_for :answers,
                                reject_if: :reject_answer,
                                allow_destroy: true

  before_create :set_default_position

  private

  # Method to check if we reject the answer.
  #
  # We reject the answer if the content is empty and the questions doesn't already exists.
  # If the answer exists and the content is empty, we add the attribute to delete the answer.
  #
  # @return Boolean
  def reject_answer(attributes)
    exists = attributes[:id].present?
    if exists and attributes[:content].blank?
      attributes.merge!({ :_destroy => 1 })
    end

    return (!exists and attributes[:content].blank?)
  end

  # Set the default position.
  #
  # @return
  def set_default_position
    if position.nil?
      self.position = guide.questions.count + 1
    end
  end
end
