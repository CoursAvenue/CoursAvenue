# encoding: utf-8
class HarmonizedStructureType < ActiveRecord::Migration
  def up
    Structure.all.each do |structure|
      case structure.structure_type
      when 'Ecole privée'
        structure.update_column :structure_type, 'structures.company'
      when 'Municipal'
        structure.update_column :structure_type, 'structures.board'
      when 'Association'
        structure.update_column :structure_type, 'structures.association'
      when 'Musée'
        structure.update_column :structure_type, 'structures.board'
      when 'Indépendant'
        structure.update_column :structure_type, 'structures.independant'
      when ''
        structure.update_column :structure_type, 'structures.company'
      when nil
        structure.update_column :structure_type, 'structures.company'
      end
    end
  end

  def down
  end
end
