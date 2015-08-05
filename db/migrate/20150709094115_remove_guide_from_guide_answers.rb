class RemoveGuideFromGuideAnswers < ActiveRecord::Migration
  def change
    remove_column(:guide_answers, :guide_id)
  end
end
