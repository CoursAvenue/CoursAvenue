class CreateGiftCertificates < ActiveRecord::Migration
  def change
    create_table :gift_certificates do |t|
      t.references :structure, index: true
      t.string :name
      t.float :amount
      t.string :description

      t.timestamps
    end
  end
end
