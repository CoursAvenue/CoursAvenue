class RemoveCorruptedWebsiteUrlAndFacebookUrl < ActiveRecord::Migration
  def change
    structures = Structure.where(Structure.arel_table[:website].eq('').or(
                                 Structure.arel_table[:website].eq(nil)).or(
                                 Structure.arel_table[:website].eq('http://')) )
    structures.update_all website: nil

    structures = Structure.where(Structure.arel_table[:facebook_url].eq('').or(
                                 Structure.arel_table[:facebook_url].eq(nil)).or(
                                 Structure.arel_table[:facebook_url].eq('http://')) )
    structures.update_all facebook_url: nil
  end
end
