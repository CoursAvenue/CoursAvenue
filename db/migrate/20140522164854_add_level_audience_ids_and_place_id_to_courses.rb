class AddLevelAudienceIdsAndPlaceIdToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :audience_ids, :string
    add_column :courses, :level_ids, :string
    add_column :courses, :min_age_for_kid, :integer
    add_column :courses, :max_age_for_kid, :integer
  end
end
