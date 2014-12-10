class AddDeletedAtToFaqSection < ActiveRecord::Migration
  def change
    add_column :faq_sections, :deleted_at, :datetime
    add_column :faq_questions, :deleted_at, :datetime
  end
end
