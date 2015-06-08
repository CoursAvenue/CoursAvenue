class AddTokenToGiftCertificateVouchers < ActiveRecord::Migration
  def change
    add_column :gift_certificate_vouchers, :token, :string
    add_index :gift_certificate_vouchers, :token, unique: true
  end
end
