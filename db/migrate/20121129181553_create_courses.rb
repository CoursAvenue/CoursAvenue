class CreateCourses < ActiveRecord::Migration
  def change
    create_table :courses do |t|
      t.string  :type
      t.string  :name
      t.string  :frequency
      t.text    :description
      t.boolean :is_promoted       , default: false
      t.boolean :has_online_payment, default: false
      t.text    :info
      t.text    :registration_date
      t.boolean :is_individual
      t.boolean :is_for_handicaped
      t.text    :trial_lesson_info
      t.text    :price_details
      t.text    :price_info
      t.text    :conditions
      t.text    :partner_rib_info
      t.boolean :audition_mandatory
      t.text    :refund_condition
      t.boolean :can_be_joined_during_year


      t.references :structure
      t.timestamps
    end
  end
end
