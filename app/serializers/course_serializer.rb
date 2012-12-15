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
             :teacher_name

  has_one :planning
  has_one :price

end
