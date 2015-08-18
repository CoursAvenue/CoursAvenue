class Structure::DuplicateList < ActiveRecord::Base
  include Concerns::HstoreHelper

  belongs_to :structure
  store_accessor :metadata, :duplicate_ids

  define_array_accessor_for :metadata, :duplicate_ids

  def duplicates
    return [] if duplicate_ids.empty?

    duplicate_ids.map do |id|
      Structure.where(id: id).first
    end.compact
  end

  def self.save_potential_duplicates
    Structure.active_and_enabled.each do |structure|
      duplicates = StructureSearch.potential_duplicates(structure)
      next if duplicates.empty?

      list = structure.duplicate_list || structure.create_duplicate_list
      list.duplicate_ids = duplicates.map(&:id)
      list.save
    end
  end
end
