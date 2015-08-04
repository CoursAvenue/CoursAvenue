class AddPositionToGuideAnswers < ActiveRecord::Migration
  def change
    add_column :guide_answers, :position, :integer
  end
end
