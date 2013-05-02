# encoding: utf-8
class Reservation < ActiveRecord::Base

  include PlanningsHelper
  include PricesHelper

  attr_accessible :course_id, :planning_id, :price_id, :book_ticket_id,
                  :name, :email,
                  :name_on_card, :billing_address_first_line, :billing_address_second_line,
                  :city_name, :zip_code, :phone, :start_date, :nb_participants

  validates :course_id, :name, :email, presence: true

  has_one    :structure, through: :course
  has_one    :place    , through: :course
  belongs_to :course
  belongs_to :planning
  belongs_to :price
  belongs_to :book_ticket
  has_many   :participants

  before_save :set_nb_participants

  def email_subject_for_user
    "Réservation de : #{self.course.name}"
  end

  def email_subject_for_structure
    "CoursAvenue - Un élève veut réserver un de vos cours"
  end

  def readable_price
    if price
      if price.has_promo?
        "#{readable_amount(price.promo_amount)}€ au lieu de #{readable_amount(price.amount)}€ (#{I18n.t(price.libelle)})"
      else
        "#{readable_amount(price.amount)}€ (#{I18n.t(price.libelle)})"
      end
    elsif book_ticket
      if book_ticket.has_promo?
        "#{readable_amount(book_ticket.promo_amount)}€ au lieu de #{readable_amount(book_ticket.amount)}€ (#{I18n.t(book_ticket.libelle)})"
        else
        "#{readable_amount(book_ticket.amount)}€ (#{I18n.t(book_ticket.libelle)})"
      end
    end
  end

  private

  def set_nb_participants
    nb_participants ||= 1
  end
end
