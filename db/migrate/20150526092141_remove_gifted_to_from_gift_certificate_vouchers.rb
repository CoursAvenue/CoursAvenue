class RemoveGiftedToFromGiftCertificateVouchers < ActiveRecord::Migration
  def change
    remove_column :gift_certificate_vouchers, :gifted_to
  end
end
