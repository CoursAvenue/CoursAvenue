class CreateStructures < ActiveRecord::Migration
  def change
    create_table :structures do |t|
      t.string  :structure_type
      t.string  :name
      t.string  :place_name
      t.text    :info
      t.text    :registration_info
      t.text    :street
      t.string  :zip_code
      t.text    :adress_info
      t.boolean :has_handicap_access
      t.boolean :is_professional
      t.integer :nb_room
      t.string  :website
      t.string  :phone_number
      t.string  :mobile_phone_number
      t.string  :email_address
      t.boolean :accepts_holiday_vouchers
      t.boolean :accepts_ancv_sports_coupon
      t.boolean :accepts_leisure_tickets
      t.boolean :accepts_afdas_funding
      t.boolean :accepts_dif_funding
      t.boolean :accepts_cif_funding
      t.boolean :has_annual_course_only

      # For registration info
      t.boolean :has_registration_form
      t.boolean :needs_photo_id_for_registration
      t.boolean :needs_id_copy_for_registration
      t.boolean :needs_medical_certificate_for_registration # certificat médical de moins de 3 mois
      t.boolean :needs_insurance_attestation_for_registration # attestation d'assurance

      t.references :city
      t.timestamps
    end
    add_index :structures, :city_id
  end
end
