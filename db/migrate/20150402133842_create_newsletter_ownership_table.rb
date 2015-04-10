class CreateNewsletterOwnershipTable < ActiveRecord::Migration
  def up
    create_table :newsletter_bloc_ownerships , id: false do |t|
      t.integer :bloc_id
      t.integer :sub_bloc_id
    end

    # We manually set the name because the generated name is fucking too long.
    add_index :newsletter_bloc_ownerships, [:bloc_id, :sub_bloc_id], unique: true, name: 'index_newsletter_bloc_ownerships_on_bloc_and_sub_bloc'
    add_index :newsletter_bloc_ownerships, [:sub_bloc_id, :bloc_id], unique: true, name: 'index_newsletter_bloc_ownerships_on_sub_bloc_and_bloc'
  end

  def down
    remove_index :newsletter_bloc_ownerships, column: [:sub_bloc_id, :bloc_id], name: 'index_newsletter_bloc_ownerships_on_sub_bloc_and_bloc'
    remove_index :newsletter_bloc_ownerships, column: [:bloc_id, :sub_bloc_id], name: 'index_newsletter_bloc_ownerships_on_bloc_and_sub_bloc'

    drop_table :newsletter_bloc_ownerships
  end
end
