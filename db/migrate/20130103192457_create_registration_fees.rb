class CreateRegistrationFees < ActiveRecord::Migration
  def change
    create_table :registration_fees do |t|
      t.decimal :price
      t.boolean :for_kid
      t.references :course

      t.timestamps
    end
  end
end
