class Course < ActiveRecord::Base

  has_one :planning, dependent: :destroy
  has_one :price   , dependent: :destroy
  belongs_to :course_group

  attr_accessible :course_info_1,
                  :course_info_2,
                  :min_age_for_kid,
                  :max_age_for_kid,
                  :is_individual,
                  :annual_membership_mandatory,
                  :is_for_handicaped,
                  :registration_date,
                  :teacher_name,
                  :has_online_payment,
                  :formule_1,
                  :formule_2,
                  :formule_3,
                  :formule_4,
                  :conditions,
                  :nb_place_available,
                  :partner_rib_info,
                  :audition_mandatory,
                  :refund_condition,
                  :promotion,
                  :cant_be_joined_during_year

end
