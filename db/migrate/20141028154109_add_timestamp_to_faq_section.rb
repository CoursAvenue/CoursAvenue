class AddTimestampToFaqSection < ActiveRecord::Migration
  def change
    add_column(:faq_sections, :created_at, :datetime)
    add_column(:faq_sections, :updated_at, :datetime)
  end
end
