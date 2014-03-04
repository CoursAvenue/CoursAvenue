class Passion < ActiveRecord::Base
  extend ActiveHashHelper

  ######################################################################
  # Relations                                                          #
  ######################################################################
  belongs_to :user

  has_and_belongs_to_many :subjects

  define_has_many_for :level
  define_has_many_for :passion_frequency
  define_has_many_for :passion_expectation
  define_has_many_for :passion_reason
  define_has_many_for :passion_for
  define_has_many_for :passion_time_slot

  attr_accessible :practiced, :subjects, :subject_ids, :info, :level_ids,
                  :passion_frequency_ids, :passion_expectation_ids, :passion_reason_ids,
                  :passion_for_ids, :passion_time_slot_ids


  ######################################################################
  # Scopes                                                             #
  ######################################################################
  scope :practiced, -> { where(practiced: true) }
  scope :wanted,    -> { where(practiced: false) }

  ######################################################################
  # Validations                                                        #
  ######################################################################
  validates :subjects, presence: true

end
