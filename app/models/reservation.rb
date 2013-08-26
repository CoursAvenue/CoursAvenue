# encoding: utf-8
class Reservation < ActiveRecord::Base

  include PlanningsHelper
  include PricesHelper

  attr_accessible :user, :reservable_type, :reservable_id

  validates :user, :reservable, presence: true

  belongs_to :user
  belongs_to :reservable, polymorphic: true

  def email_subject_for_user
    "Votre réservation sur CoursAvenue"
  end

  def email_subject_for_structure
    "CoursAvenue - Un élève veut réserver un de vos cours"
  end

  def structure
    if self.reservable.is_a? Structure
      self.reservable
    else
      self.reservable.structure
    end
  end
end
