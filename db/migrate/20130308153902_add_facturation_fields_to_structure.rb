class AddFacturationFieldsToStructure < ActiveRecord::Migration
  def change
    add_column :structures, :siret, :string
    add_column :structures, :tva_intracom_number, :string
    add_column :structures, :structure_status, :string

    add_column :structures, :billing_contact_first_name, :string
    add_column :structures, :billing_contact_last_name, :string
    add_column :structures, :billing_contact_phone_number, :string
    add_column :structures, :billing_contact_email, :string

    add_column :structures, :bank_name, :string
    add_column :structures, :bank_iban, :string
    add_column :structures, :bank_bic, :string
  end
end
