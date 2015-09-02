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

  # TODO (aliou): This is a bad idea.
  # Get the actual price for the participant. Either the price it has, or the trial price.
  #
  # @return a price or nil
  def individual_price
    if price.present?
      price
    elsif !participation_request.course.no_trial?
      participation_request.course.prices.where(type: 'Price::Trial').first
    end
  end
end
