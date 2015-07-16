class RemoveGuideAgeRestrictions < ActiveRecord::Migration
  def up
    drop_table :guide_age_restrictions
  end

  def down
    create_table :guide_age_restrictions do |t|
      t.integer :min_age
      t.integer :max_age
      t.references :guide, index: true

      t.timestamps
    end
  end
end
