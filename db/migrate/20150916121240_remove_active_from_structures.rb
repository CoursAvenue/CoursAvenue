class RemoveActiveFromStructures < ActiveRecord::Migration
  def change
    bar = ProgressBar.new(Structure.where.not(sleeping_structure_id: nil).count)
    Structure.where.not(sleeping_structure_id: nil).each do |structure|
      sleeping_structure = Structure.where(id: structure.sleeping_structure_id).first
      next if sleeping_structure.nil?
      sleeping_structure.delay.destroy
      structure.indexable_cards.map{ |card| card.delay.algolia_index! }
      bar.increment!
    end
    remove_column :structures, :active, false
    remove_column :structures, :sleeping_structure_id, false
  end
end
