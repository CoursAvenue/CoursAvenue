class Structure < ActiveRecord::Base

  has_many :courses
  has_many :renting_rooms

  # attr_accessible :logo
  # attr_accessible :photo
  # has_attached_file :logo
  # has_attached_file :photo

  validates :name, :presence   => true
  validates :name, :uniqueness => true

  attr_accessible :adress_info,
                  :structure_type,
                  :name,
                  :annual_price_adult,
                  :annual_price_child,
                  :street,
                  :zip_code,
                  :annual_membership_mandatory,
                  :closed_days,
                  :has_handicap_access,
                  :is_professional,
                  :room_number,
                  :location_room_number,
                  :website,
                  :newsletter_address,
                  :online_reservation,
                  :onlne_reservation_mandatory,
                  :has_trial_lesson,
                  :trial_lesson_info,
                  :trial_lesson_price,
                  :trial_lesson_info_2,
                  :annual_membership_mandatory,
                  :registration_info,
                  :canceleable_without_fee,
                  :nb_days_before_cancelation,
                  :phone_number,
                  :mobile_phone_number,
                  :email_address,
                  :email_address_2,
                  :contact_name,
                  :accepts_holiday_vouchers,
                  :accepts_ancv_sports_coupon,
                  :accepts_leisure_tickets,
                  :accepts_afdas_funding,
                  :accepts_dif_funding,
                  :has_multiple_place

end
