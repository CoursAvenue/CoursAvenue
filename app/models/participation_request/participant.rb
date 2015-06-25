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
    price.present? ? price.final_amount * number : 0
  end
end
