class AddUsedFlagToGiftCertificateVouchers < ActiveRecord::Migration
  def change
    add_column :gift_certificate_vouchers, :used, :boolean, default: false
  end
end
