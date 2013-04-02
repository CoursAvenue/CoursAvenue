# encoding: utf-8
class Reservation < ActiveRecord::Base

  include PlanningsHelper

  attr_accessible :course_id, :planning_id, :price_id, :first_name, :last_name, :email, :name_on_card, :billing_address_first_line, :billing_address_second_line, :city_name, :zip_code, :phone, :start_date

  validates :course_id, :planning_id, :price_id, :first_name, :last_name, :email, :billing_address_first_line, :city_name, :zip_code, :phone, presence: true
  has_one    :structure, through: :course
  belongs_to :course
  belongs_to :planning
  belongs_to :price
  has_many   :participants

  def full_name
    "#{first_name} #{last_name}"
  end

  def email_subject
    "Réservation de : #{self.course.name} le #{planning.to_s}"
  end
end
