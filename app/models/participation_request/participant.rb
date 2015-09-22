# encoding: utf-8
class ParticipationRequest::Participant < ActiveRecord::Base
  acts_as_paranoid

  attr_accessible :number, :price_id, :participation_request_id

  ######################################################################
  # Relations                                                          #
  ######################################################################
  belongs_to :price
  belongs_to :participation_request

  def self.table_name_prefix
    'participation_request_'
  end

  def total_price
    individual_price.present? ? individual_price.final_amount * number : 0
  end

  # Get the actual price for the participant.
  # It's either the price we already have, the trial price if there's one or the first price.
  #
  # @return a price or nil
  def individual_price
    if price.present?
      price
    elsif !participation_request.course.no_trial?
      participation_request.course.prices.where(type: 'Price::Trial').first ||
        participation_request.course.prices.first
    end
  end
end
