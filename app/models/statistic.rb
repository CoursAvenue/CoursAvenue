# encoding: utf-8
class Statistic < ActiveRecord::Base
  acts_as_paranoid

  ######################################################################
  # Relations                                                             #
  ######################################################################
  belongs_to :structure

  ACTION_TYPES = %w(impression view action)

  attr_accessible :action_type, :structure_id, :user_fingerprint, :infos, :ip_address

  ######################################################################
  # Scopes                                                             #
  ######################################################################
  scope :impressions,          -> { where( action_type: 'impression') }
  scope :views,                -> { where( action_type: 'view') }
  scope :actions,              -> { where( action_type: 'action') }
  scope :structure_go_premium, -> { where( arel_table[:action_type].matches('structure_go_premium_%') ) }


  # Creates a statistic when a structure appears in the results of a search
  # @param structure_id Integer Structure id that appeared in the search
  # @param user User who searched for it
  # @param fingerprint String, Fingerprint (hash) generated client side to identify a unique user
  # @param infos=nil String, more info on the stat
  #
  # @return Statistic
  def self.print(structure_id, user, fingerprint, ip_address, infos=nil)
    Statistic.create(action_type: 'impression', structure_id: structure_id, user_fingerprint: fingerprint, ip_address: ip_address)
  end


  # Creates a statistic when a structure has been viewed (#show action)
  # @param structure_id Integer Structure id that appeared in the search
  # @param user User who searched for it
  # @param fingerprint String, Fingerprint (hash) generated client side to identify a unique user
  # @param infos=nil String, more info on the stat
  #
  # @return Statistic
  def self.view(structure_id, user, fingerprint, ip_address, infos=nil)
    Statistic.create(action_type: 'view', structure_id: structure_id, user_fingerprint: fingerprint, ip_address: ip_address)
  end

  # Creates a statistic when there has been an action on a structure (eg. contact etc.)
  # @param structure_id Integer Structure id that appeared in the search
  # @param user User who searched for it
  # @param fingerprint String, Fingerprint (hash) generated client side to identify a unique user
  # @param infos=nil String, more info on the stat
  #
  # @return Statistic
  def self.action(structure_id, user, fingerprint, ip_address, infos=nil)
    Statistic.create(action_type: 'action', structure_id: structure_id, user_fingerprint: fingerprint, ip_address: ip_address, infos: infos )
  end

  # Creates a statistic regarding the action name
  # @param action_name String Type of an action
  # @param structure_id Integer Structure id that appeared in the search
  # @param user User who searched for it
  # @param fingerprint String, Fingerprint (hash) generated client side to identify a unique user
  # @param infos=nil String, more info on the stat
  #
  # @return Statistic
  def self.create_action(action_name, structure_id, user, fingerprint, ip_address, infos=nil)
    case action_name
    when 'impression'
      stat = Statistic.print(structure_id, user, fingerprint, ip_address, infos)
    when 'action'
      stat = Statistic.action(structure_id, user, fingerprint, ip_address, infos)
    when 'view'
      stat = Statistic.view(structure_id, user, fingerprint, ip_address, infos)
    end
    return stat
  end

  # Total view count
  # @param structure Structure concerned
  # @param from_date=(Date.today - 10.years Date Date from where to start
  #
  # @return Integer number of view counts since `from_date`
  def self.view_count(structure, from_date=(Date.today - 10.years))
    return structure.statistics.views.where( Statistic.arel_table[:created_at].gt(from_date) )
                               .order('DATE(created_at) ASC')
                               .group('DATE(created_at)')
                               .select('DATE(created_at) as created_at, COUNT(DISTINCT(user_fingerprint)) as user_count')
                               .map(&:user_count).reduce(&:+)

  end

  # Total impression count
  # @param structure Structure concerned
  # @param from_date=(Date.today - 10.years Date Date from where to start
  #
  # @return Integer number of view counts since `from_date`
  def self.impression_count(structure, from_date=(Date.today - 10.years))
    return structure.statistics.impressions.where( Statistic.arel_table[:created_at].gt(from_date) )
                                           .order('DATE(created_at) ASC')
                                           .group('DATE(created_at)')
                                           .select('DATE(created_at) as created_at, COUNT(DISTINCT(user_fingerprint)) as user_count')
                                           .map(&:user_count).reduce(&:+)

  end

  # Total action count
  # @param structure Structure concerned
  # @param from_date=(Date.today - 10.years Date Date from where to start
  #
  # @return Integer number of view counts since `from_date`
  def self.action_count(structure, from_date=(Date.today - 10.years))
    return structure.statistics.actions.where( Statistic.arel_table[:created_at].gt(from_date) )
                                       .order('DATE(created_at) ASC')
                                       .group('DATE(created_at)')
                                       .select('DATE(created_at) as created_at, COUNT(DISTINCT(user_fingerprint)) as user_count')
                                       .map(&:user_count).reduce(&:+)

  end

  # Total telephone action count
  # @param structure Structure concerned
  # @param from_date=(Date.today - 10.years Date Date from where to start
  #
  # @return Integer number of view counts since `from_date`
  def self.telephone_count(structure, from_date=(Date.today - 10.years))
    return structure.statistics.actions.where( Statistic.arel_table[:created_at].gt(from_date) )
                                       .where(infos: 'telephone')
                                       .order('DATE(created_at) ASC')
                                       .group('DATE(created_at)')
                                       .select('DATE(created_at) as created_at, COUNT(DISTINCT(user_fingerprint)) as user_count')
                                       .map(&:user_count).reduce(&:+) || 0

  end

  # Total website action count
  # @param structure Structure concerned
  # @param from_date=(Date.today - 10.years Date Date from where to start
  #
  # @return Integer number of view counts since `from_date`
  def self.website_count(structure, from_date=(Date.today - 10.years))
    return structure.statistics.actions.where( Statistic.arel_table[:created_at].gt(from_date) )
                                       .where(infos: 'website')
                                       .order('DATE(created_at) ASC')
                                       .group('DATE(created_at)')
                                       .select('DATE(created_at) as created_at, COUNT(DISTINCT(user_fingerprint)) as user_count')
                                       .map(&:user_count).reduce(&:+) || 0

  end

end
