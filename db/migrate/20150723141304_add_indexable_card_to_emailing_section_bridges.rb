class AddIndexableCardToEmailingSectionBridges < ActiveRecord::Migration
  def change
    add_reference :emailing_section_bridges, :indexable_card, index: true
  end
end
