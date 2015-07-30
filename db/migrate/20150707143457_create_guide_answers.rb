class CreateGuideAnswers < ActiveRecord::Migration
  def change
    create_table :guide_answers do |t|
      t.references :guide, index: true
      t.references :guide_question, index: true
      t.string :content

      t.timestamps
    end
  end
end
