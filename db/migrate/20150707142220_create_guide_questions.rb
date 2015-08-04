class CreateGuideQuestions < ActiveRecord::Migration
  def change
    create_table :guide_questions do |t|
      t.references :guide, index: true
      t.integer :ponderation
      t.string :content

      t.timestamps
    end
  end
end
