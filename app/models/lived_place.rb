# encoding: utf-8
class LivedPlace < ActiveRecord::Base

  ######################################################################
  # Relations                                                          #
  ######################################################################
  belongs_to :user
  belongs_to :city

  attr_accessible :user, :city, :city_id, :user_id, :zip_code, :radius

  ######################################################################
  # Validations                                                        #
  ######################################################################
  validates :city, :user, presence: true

end
