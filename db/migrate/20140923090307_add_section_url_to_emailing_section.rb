class AddSectionUrlToEmailingSection < ActiveRecord::Migration
  def change
    add_column :emailing_sections, :url, :string
  end
end
