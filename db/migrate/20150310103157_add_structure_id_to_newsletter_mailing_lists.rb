class AddStructureIdToNewsletterMailingLists < ActiveRecord::Migration
  def change
    add_column :newsletter_mailing_lists, :structure_id, :integer
    add_index :newsletter_mailing_lists, :structure_id
  end
end
