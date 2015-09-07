class Passion < ActiveRecord::Base
  include Concerns::ActiveHashHelper

  ######################################################################
  # Relations                                                          #
  ######################################################################
  belongs_to :user

  has_and_belongs_to_many :subjects

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
