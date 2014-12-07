class AddHasPromotionColumnToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :has_promotion, :boolean
  end
end
