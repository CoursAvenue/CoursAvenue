class AddColorToGuideQuestions < ActiveRecord::Migration
  def change
    add_column :guide_questions, :color, :string
  end
end
