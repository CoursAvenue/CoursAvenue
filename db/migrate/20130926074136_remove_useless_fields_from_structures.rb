class RemoveUselessFieldsFromStructures < ActiveRecord::Migration
  def up
    remove_column :structures, :has_registration_form
    remove_column :structures, :needs_photo_id_for_registration
    remove_column :structures, :needs_id_copy_for_registration
    remove_column :structures, :needs_medical_certificate_for_registration
    remove_column :structures, :needs_insurance_attestation_for_registration
    remove_column :structures, :siret
    remove_column :structures, :tva_intracom_number
    remove_column :structures, :structure_status
    remove_column :structures, :billing_contact_first_name
    remove_column :structures, :billing_contact_last_name
    remove_column :structures, :billing_contact_phone_number
    remove_column :structures, :billing_contact_email
    remove_column :structures, :bank_name
    remove_column :structures, :bank_iban
    remove_column :structures, :bank_bic

  end

  def down
    add_column :structures, :has_registration_form, :string
    add_column :structures, :needs_photo_id_for_registration, :string
    add_column :structures, :needs_id_copy_for_registration, :string
    add_column :structures, :needs_medical_certificate_for_registration, :string
    add_column :structures, :needs_insurance_attestation_for_registration, :string
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
