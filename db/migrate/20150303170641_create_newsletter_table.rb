class CreateNewsletterTable < ActiveRecord::Migration
  def change
    create_table :newsletters do |t|
      t.string     :title
      t.text       :content
      t.string     :state

      t.string     :object
      t.string     :sender_name
      t.string     :reply_to

      t.references :structure

      t.timestamps
    end
  end
end
