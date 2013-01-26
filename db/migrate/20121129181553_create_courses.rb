class CreateCourses < ActiveRecord::Migration
  def change
    create_table :courses do |t|
      t.string  :type
      t.string  :name
      t.text    :description
      t.boolean :has_online_payment, default: false
      t.boolean :has_promotion     , default: false
      t.text    :course_info_1
      t.text    :course_info_2
      t.text    :registration_date
      t.text    :teacher_name
      t.integer :max_age_for_kid
      t.integer :min_age_for_kid
      t.boolean :is_individual
      t.boolean :annual_membership_mandatory
      t.boolean :is_for_handicaped
      t.text    :trial_lesson_info
      t.text    :price_details
      t.text    :price_info_1
      t.text    :price_info_2
      t.text    :conditions
      t.text    :partner_rib_info
      t.boolean :audition_mandatory
      t.text    :refund_condition
      t.boolean :cant_be_joined_during_year


      t.references :structure
      t.references :discipline

      t.timestamps
    end
  end
end
