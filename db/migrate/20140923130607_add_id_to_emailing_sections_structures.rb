class AddIdToEmailingSectionsStructures < ActiveRecord::Migration
  def change
    add_column :emailing_sections_structures, :id, :primary_key
    add_column :emailing_sections_structures, :media_id, :integer
  end
end
