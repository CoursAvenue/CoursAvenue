class AddIsLogoToEmailingSectionBridge < ActiveRecord::Migration
  def change
    add_column :emailing_section_bridges, :is_logo, :boolean
  end
end
