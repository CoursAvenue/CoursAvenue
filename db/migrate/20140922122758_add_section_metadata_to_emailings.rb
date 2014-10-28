class AddSectionMetadataToEmailings < ActiveRecord::Migration
  def change
    add_column :emailings, :section_metadata_one, :string
    add_column :emailings, :section_metadata_two, :string
    add_column :emailings, :section_metadata_three, :string
  end
end
