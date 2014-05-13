class CreatePriceGroups < ActiveRecord::Migration
  def change
    create_table :price_groups do |t|
      t.string     :name
      t.string     :course_type
      t.text       :details
      t.boolean    :premium_visible

      t.references :structure

      t.time       :deleted_at
      t.timestamps
    end

    add_column :prices, :price_group_id, :integer
    add_column :courses, :price_group_id, :integer
  end
end
