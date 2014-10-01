class RemoveUselessAttributesInCourses < ActiveRecord::Migration
  def change
    remove_column :courses, :price_details
    remove_column :courses, :has_online_payment
    remove_column :courses, :registration_date
    remove_column :courses, :is_for_handicaped
    remove_column :courses, :trial_lesson_info
    remove_column :courses, :conditions
    remove_column :courses, :partner_rib_info
    remove_column :courses, :audition_mandatory
    remove_column :courses, :refund_condition
  end
end
