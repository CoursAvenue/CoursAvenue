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


  # Creates a statistic when a structure appears in the results of a search
  # @param structure_id Integer Structure id that appeared in the search
  # @param user User who searched for it
  # @param fingerprint=generate_fingerprint String, Fingerprint (hash) generated client side to identify a unique user
  # @param infos=nil String, more info on the stat
  #
  # @return Statistic
  def self.print(structure_id, user, fingerprint=generate_fingerprint, infos=nil)
    Statistic.create(action_type: 'impression', structure_id: structure_id, user_fingerprint: fingerprint)
  end


  # Creates a statistic when a structure has been viewed (#show action)
  # @param structure_id Integer Structure id that appeared in the search
  # @param user User who searched for it
  # @param fingerprint=generate_fingerprint String, Fingerprint (hash) generated client side to identify a unique user
  # @param infos=nil String, more info on the stat
  #
  # @return Statistic
  def self.view(structure_id, user, fingerprint=generate_fingerprint, infos=nil)
    Statistic.create(action_type: 'view', structure_id: structure_id, user_fingerprint: fingerprint)
  end

  # Creates a statistic when there has been an action on a structure (eg. contact etc.)
  # @param structure_id Integer Structure id that appeared in the search
  # @param user User who searched for it
  # @param fingerprint=generate_fingerprint String, Fingerprint (hash) generated client side to identify a unique user
  # @param infos=nil String, more info on the stat
  #
  # @return Statistic
  def self.action(structure_id, user, fingerprint=generate_fingerprint, infos=nil)
    Statistic.create(action_type: 'action', structure_id: structure_id, user_fingerprint: fingerprint, infos: infos )
  end

  # Creates a statistic regarding the action name
  # @param action_name String Type of an action
  # @param structure_id Integer Structure id that appeared in the search
  # @param user User who searched for it
  # @param fingerprint=generate_fingerprint String, Fingerprint (hash) generated client side to identify a unique user
  # @param infos=nil String, more info on the stat
  #
  # @return Statistic
  def self.create_action(action_name, structure_id, user, fingerprint=generate_fingerprint, infos=nil)
    case action_name
    when 'print'
      Statistic.print(structure_id, user, fingerprint, infos)
    when 'action'
      Statistic.action(structure_id, user, fingerprint, infos)
    when 'view'
      Statistic.view(structure_id, user, fingerprint, infos)
    end
  end

  private

  #
  # Generate a random number if the fingerprint is nil
  # Fingerprint is important because it will be unique when looking at the stats
  # and if nil, the stat won't show up.
  #
  # @return String Fingerprint with one character longer than the fingerprint
  # generated client side to be able to identify it
  def self.generate_fingerprint
    (rand * 10000000000).to_i.to_s
  end
end
