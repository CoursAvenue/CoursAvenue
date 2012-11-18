class CreateStructures < ActiveRecord::Migration
  def change
    create_table :structures do |t|
      t.string  :structure_type
      t.string  :name
      t.text    :street
      t.string  :zip_code
      t.string  :adress_info
      t.integer :annual_price_child
      t.integer :annual_price_adult
      t.boolean :annual_membership_mandatory?
      t.string  :closed_days
      t.boolean :has_handicap_access
      t.boolean :is_professional?
      t.integer :room_number
      t.integer :location_room_number
      t.string  :website
      t.string  :newsletter_address
      t.boolean :online_reservation?
      t.boolean :onlne_reservation_mandatory?
      t.boolean :has_trial_lesson?
      t.text    :trial_lesson_info
      t.string  :trial_lesson_price
      t.text    :trial_lesson_info_2
      t.boolean :annual_membership_mandatory?
      t.text    :registration_info
      t.boolean :canceleable_without_fee?
      t.integer :nb_days_before_cancelation
      t.string  :phone_number
      t.string  :mobile_phone_number
      t.string  :email_address
      t.string  :email_address_2
      t.string  :contact_name
      t.boolean :accepts_holiday_vouchers?
      t.boolean :accepts_ancv_sports_coupon?
      t.boolean :accepts_leisure_tickets?
      t.boolean :accepts_afdas_funding?
      t.boolean :accepts_dif_funding?
      t.boolean :has_multiple_place?

      t.timestamps
    end
  end
end
