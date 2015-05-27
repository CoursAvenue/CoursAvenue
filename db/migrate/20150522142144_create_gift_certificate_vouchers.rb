class CreateGiftCertificateVouchers < ActiveRecord::Migration
  def change
    create_table :gift_certificate_vouchers do |t|
      t.references :gift_certificate, index: true
      t.string     :stripe_charge_id
      t.references :user, index: true
      t.string     :gifted_to

      t.timestamps
    end
    add_index :gift_certificate_vouchers, :stripe_charge_id, unique: true
  end
end
