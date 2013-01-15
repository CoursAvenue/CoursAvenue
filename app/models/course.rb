class Course < ActiveRecord::Base

  has_one   :planning         , dependent: :destroy

  has_many  :registration_fees, dependent: :destroy
  belongs_to :course_group

  after_commit   :update_course_group
  before_destroy :update_course_group_before_destroy

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
                  :cant_be_joined_during_year,
                  :trial_lesson_info,
                  :price_details,
                  :price_info_1,
                  :price_info_2

  def update_course_group
    self.course_group.update_has_promotion
    self.course_group.has_online_payment = true if self.has_online_payment?
    self.course_group.save
  end

  def update_course_group_before_destroy
    self.course_group.update_has_promotion
  end
end
