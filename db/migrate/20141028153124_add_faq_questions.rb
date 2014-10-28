class AddFaqQuestions < ActiveRecord::Migration
  def change
    create_table :faq_questions do |t|
      t.belongs_to :faq_section
      t.string :question
      t.text :answer

      t.timestamps
    end
  end
end
