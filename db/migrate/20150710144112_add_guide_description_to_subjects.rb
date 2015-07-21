class AddGuideDescriptionToSubjects < ActiveRecord::Migration
  def change
    add_column :subjects, :guide_description, :text
  end
end
