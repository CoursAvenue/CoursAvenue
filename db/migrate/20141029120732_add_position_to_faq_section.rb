class AddPositionToFaqSection < ActiveRecord::Migration
  def change
    add_column :faq_sections, :position, :integer
  end
end
