class RenameEmailingSectionsStructuresToEmailingSectionBridges < ActiveRecord::Migration
  def change
    rename_table :emailing_sections_structures, :emailing_section_bridges
  end
end
