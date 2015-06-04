class ChangeDescriptionTypeForGiftCertificates < ActiveRecord::Migration
  def up
    change_column :gift_certificates, :description, :text
  end

  def down
    change_column :gift_certificates, :description, :string
  end
end
