class CreateGuideAgeRestrictions < ActiveRecord::Migration
  def change
    create_table :guide_age_restrictions do |t|
      t.integer :min_age
      t.integer :max_age
      t.references :guide, index: true

      t.timestamps
    end
  end
end
