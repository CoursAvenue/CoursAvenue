class CreateNewsletterBlocs < ActiveRecord::Migration
  def change
    create_table :newsletter_blocs do |t|
      t.string :type
      t.references :newsletter
      t.integer :position

      t.timestamps
    end
  end
end
