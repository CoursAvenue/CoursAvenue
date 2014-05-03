# encoding: utf-8
class Statistic < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :structure

  ACTION_TYPES = %w(impression view contact action)

  attr_accessible :action_type, :structure_id

end
