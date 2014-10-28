class AddEmailingSectionsStructuresTable < ActiveRecord::Migration
  def change
    create_table :emailing_sections_structures, :id => false do |t|
      t.references :emailing_section, :structure
    end
    add_index :emailing_sections_structures, [:emailing_section_id, :structure_id], name: 'comments_subjects_index'
  end
end
