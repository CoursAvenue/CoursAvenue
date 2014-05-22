# encoding: utf-8
class Statistic < ActiveRecord::Base
  acts_as_paranoid

  ######################################################################
  # Relations                                                             #
  ######################################################################
  belongs_to :structure

  ACTION_TYPES = %w(impression view action)

  attr_accessible :action_type, :structure_id, :user_fingerprint, :infos

  ######################################################################
  # Scopes                                                             #
  ######################################################################
  scope :impressions, -> { where( action_type: 'impression') }
  scope :views,       -> { where( action_type: 'view') }
  scope :actions,     -> { where( action_type: 'action') }

  def self.print(structure_id, user, fingerprint, infos=nil)
    Statistic.create(action_type: 'impression', structure_id: structure_id, user_fingerprint: fingerprint)
  end

  def self.view(structure_id, user, fingerprint, infos=nil)
    Statistic.create(action_type: 'view', structure_id: structure_id, user_fingerprint: fingerprint)
  end

  def self.action(structure_id, user, fingerprint, infos=nil)
    Statistic.create(action_type: 'action', structure_id: structure_id, user_fingerprint: fingerprint, infos: infos )
  end

  def self.create_action(action_name, structure_id, user, fingerprint, infos=nil)
    case action_name
    when 'print'
      Statistic.print(structure_id, user, fingerprint, infos)
    when 'action'
      Statistic.action(structure_id, user, fingerprint, infos)
    when 'view'
      Statistic.view(structure_id, user, fingerprint, infos)
    end
  end
end
