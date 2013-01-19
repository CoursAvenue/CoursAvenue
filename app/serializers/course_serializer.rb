class CourseSerializer < ActiveModel::Serializer

  attributes :id,
             :course_info_1,
             :course_info_2,
             :min_age_for_kid,
             :max_age_for_kid,
             :is_individual,
             :annual_membership_mandatory,
             :is_for_handicaped,
             :registration_date,
             :teacher_name,
             :trial_lesson_info,
             :price_details,
             :price_info_1,
             :price_info_2,
             :is_lesson

  has_one :planning
  def is_lesson
    object.course_group.is_lesson?
  end

end
