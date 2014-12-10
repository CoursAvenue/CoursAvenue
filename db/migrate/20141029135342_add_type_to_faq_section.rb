class AddTypeToFaqSection < ActiveRecord::Migration
  def change
    add_column :faq_sections, :type, :string
  end
end
