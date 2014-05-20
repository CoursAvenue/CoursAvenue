# encoding: utf-8
class Statistic < ActiveRecord::Base
  acts_as_paranoid

  ######################################################################
  # Relations                                                             #
  ######################################################################
  belongs_to :structure

  ACTION_TYPES = %w(impression view contact action)

  attr_accessible :action_type, :structure_id, :user_fingerprint, :infos

  ######################################################################
  # Scopes                                                             #
  ######################################################################
  scope :impressions, -> { where( action_type: 'impression') }
  scope :views,       -> { where( action_type: 'view') }
  scope :actions,     -> { where( action_type: 'action') }
  scope :contacts,    -> { where( action_type: 'contact') }

  def self.print(structure_id, user, fingerprint)
    Statistic.create(action_type: 'impression', structure_id: structure_id, user_fingerprint: fingerprint)
  end

  def self.view(structure_id, user, fingerprint)
    Statistic.create(action_type: 'view', structure_id: structure_id, user_fingerprint: fingerprint)
  end

  def self.contact(structure_id, user, fingerprint)
    Statistic.create(action_type: 'contact', structure_id: structure_id, user_fingerprint: fingerprint)
  end

  def self.action(structure_id, user, fingerprint, infos)
    Statistic.create(action_type: 'action', structure_id: structure_id, user_fingerprint: fingerprint, infos: infos )
  end
end
