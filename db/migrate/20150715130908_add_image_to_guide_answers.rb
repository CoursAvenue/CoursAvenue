class AddImageToGuideAnswers < ActiveRecord::Migration
  def change
    add_column :guide_answers, :image, :string
  end
end
