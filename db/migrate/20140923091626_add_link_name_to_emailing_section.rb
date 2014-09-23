class AddLinkNameToEmailingSection < ActiveRecord::Migration
  def change
    add_column :emailing_sections, :link_name, :string
  end
end
