class AddPositionToGuideQuestions < ActiveRecord::Migration
  def change
    add_column :guide_questions, :position, :integer
  end
end
