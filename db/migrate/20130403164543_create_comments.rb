class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.text   :content
      t.string :name
      t.string :email
      t.integer :rating

      t.references :commentable, :polymorphic => true

      t.timestamps
    end
  end
end
