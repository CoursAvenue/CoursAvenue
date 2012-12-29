class CreateCourseGroups < ActiveRecord::Migration
  def change
    create_table :course_groups do |t|
      t.string  :type
      t.string  :name
      t.text    :description
      t.text    :trial_lesson_info
      t.boolean :has_online_payment, default: false
      t.boolean :has_promotion     , default: false

      t.references :structure
      t.references :discipline

      t.timestamps
    end
  end
end
