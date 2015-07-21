class AddSubjectsToGuideAnswers < ActiveRecord::Migration
  def change
    create_table :guide_answers_subjects, id: false do |t|
      t.belongs_to :guide_answer, index: true
      t.belongs_to :subject, index: true
    end
  end
end
