class AddStructureIdToNewsletterUsers < ActiveRecord::Migration
  def change
    add_column :newsletter_users, :structure_id, :integer
  end
end
