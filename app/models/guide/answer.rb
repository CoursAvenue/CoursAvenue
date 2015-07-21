class Guide::Answer < ActiveRecord::Base
  attr_accessible :content, :subject_ids, :remote_image_url, :image

  belongs_to :question, class_name: 'Guide::Question', foreign_key: 'guide_question_id'
  has_one :guide, through: :question

  has_and_belongs_to_many :subjects, foreign_key: 'guide_answer_id'

  validates :content,  presence: true
  validates :position, presence: true

  delegate :ponderation, to: :question, allow_nil: true

  before_create :set_default_position

  mount_uploader :image, AdminUploader

  private

  # Set the default position.
  #
  # @return
  def set_default_position
    if position.nil?
      self.position = guide.questions.count + 1
    end
  end
end
