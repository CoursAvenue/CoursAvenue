class AddTitleAndDescriptionToSubjects < ActiveRecord::Migration
  def change
    add_column :subjects, :title, :text
    add_column :subjects, :description, :text
  end
end
