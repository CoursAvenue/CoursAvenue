class Guide::Answer < ActiveRecord::Base
  attr_accessible :content, :subject_ids

  belongs_to :question, class_name: 'Guide::Question', foreign_key: 'guide_question_id'
  has_one :guide, through: :question

  has_and_belongs_to_many :subjects, foreign_key: 'guide_answer_id'

  validates :content, presence: true
end
