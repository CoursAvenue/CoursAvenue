class AddSlugToFaqSection < ActiveRecord::Migration
  def change
    add_column :faq_sections, :slug, :string
  end
end
