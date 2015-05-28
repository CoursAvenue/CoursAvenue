class AddFeeAndReceivedAmountToGiftCertificateVouchers < ActiveRecord::Migration
  def change
    add_column :gift_certificate_vouchers, :fee, :float
    add_column :gift_certificate_vouchers, :received_amount, :float
  end
end
