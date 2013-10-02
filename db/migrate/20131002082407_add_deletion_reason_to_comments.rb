class AddDeletionReasonToComments < ActiveRecord::Migration
  def change
    add_column :comments, :deletion_reason, :string
  end
end
