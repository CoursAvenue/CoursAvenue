class AddDeletedAtToGiftCertifcate < ActiveRecord::Migration
  def change
    add_column :gift_certificates, :deleted_at, :datetime
  end
end
