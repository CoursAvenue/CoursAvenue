# encoding: utf-8
class Metrics
  include Mongoid::Document
  include Mongoid::Timestamps

  ACTION_TYPES = %w(impression view action)

  ######################################################################
  # Model definition                                                   #
  ######################################################################

  field :structure_id    , type: Integer
  field :action_type     , type: String
  field :user_fingerprint, type: String
  field :infos           , type: String

  field :deleted_at      , type: DateTime
  field :ip_address      , type: String

  attr_accessible :action_type, :structure_id, :user_fingerprint, :infos, :ip_address
  ######################################################################
  # Scopes                                                             #
  ######################################################################

  scope :impressions,          -> { where( action_type: 'impression') }
  scope :views,                -> { where( action_type: 'view') }
  scope :actions,              -> { where( action_type: 'action') }
  scope :structure_go_premium, -> { where( action_type: /structure_go_premium_/) }

  ######################################################################
  # Creation methods                                                   #
  ######################################################################

  # Copies a Statistic to a Metric
  # @param statistic The original Statistic
  #
  # @return The Metric created
  def self.create_from_statistic(statistic)
    Metrics.create(structure_id: statistic.structure_id,
                   action_type: statistic.action_type,
                   user_fingerprint: statistic.user_fingerprint,
                   infos: statistic.infos,
                   ip_address: statistic.ip_address,
                   created_at: statistic.created_at)
  end

  # Creates a statistic when a structure appears in the results of a search
  # @param structure_id Integer Structure id that appeared in the search
  # @param user User who searched for it
  # @param fingerprint String, Fingerprint (hash) generated client side to identify a unique user
  # @param infos=nil String, more info on the stat
  #
  # @return Metrics
  def self.print(structure_id, user, fingerprint, ip_address, infos=nil)
    Metrics.create(action_type: 'impression', structure_id: structure_id, user_fingerprint: fingerprint, ip_address: ip_address)
  end

  # Creates a statistic when a structure has been viewed (#show action)
  # @param structure_id Integer Structure id that appeared in the search
  # @param user User who searched for it
  # @param fingerprint String, Fingerprint (hash) generated client side to identify a unique user
  # @param infos=nil String, more info on the stat
  #
  # @return Metrics
  def self.view(structure_id, user, fingerprint, ip_address, infos=nil)
    Metrics.create(action_type: 'view', structure_id: structure_id, user_fingerprint: fingerprint, ip_address: ip_address)
  end

  # Creates a statistic when there has been an action on a structure (eg. contact etc.)
  # @param structure_id Integer Structure id that appeared in the search
  # @param user User who searched for it
  # @param fingerprint String, Fingerprint (hash) generated client side to identify a unique user
  # @param infos=nil String, more info on the stat
  #
  # @return Metrics
  def self.action(structure_id, user, fingerprint, ip_address, infos=nil)
    Metrics.create(action_type: 'action', structure_id: structure_id, user_fingerprint: fingerprint, ip_address: ip_address, infos: infos )
  end

  # Creates a statistic regarding the action name
  # @param action_name String Type of an action
  # @param structure_id Integer Structure id that appeared in the search
  # @param user User who searched for it
  # @param fingerprint String, Fingerprint (hash) generated client side to identify a unique user
  # @param infos=nil String, more info on the stat
  #
  # @return Metrics
  def self.create_action(action_name, structure_id, user, fingerprint, ip_address, infos=nil)
    case action_name
    when 'impression'
      stat = Metrics.print(structure_id, user, fingerprint, ip_address, infos)
    when 'action'
      stat = Metrics.action(structure_id, user, fingerprint, ip_address, infos)
    when 'view'
      stat = Metrics.view(structure_id, user, fingerprint, ip_address, infos)
    end
    return stat
  end

  ######################################################################
  # Retrieval methods                                                  #
  ######################################################################

  # Total view count
  # @param structure Structure concerned
  # @param from_date=(Date.today - 10.years Date Date from where to start
  #
  # @return Integer number of view counts since `from_date`
  def self.view_count(structure, from_date=(Date.today - 10.years))
    return self.generic_count(structure, :views, from_date)
  end

  # Total impression count
  # @param structure Structure concerned
  # @param from_date=(Date.today - 10.years Date Date from where to start
  #
  # @return Integer number of view counts since `from_date`
  def self.impression_count(structure, from_date=(Date.today - 10.years))
    return self.generic_count(structure, :impressions, from_date)
  end

  # Total action count
  # @param structure Structure concerned
  # @param from_date=(Date.today - 10.years Date Date from where to start
  #
  # @return Integer number of view counts since `from_date`
  def self.action_count(structure, from_date=(Date.today - 10.years))
    return self.generic_count(structure, :actions, from_date)
  end

  # Total telephone action count
  # @param structure Structure concerned
  # @param from_date=(Date.today - 10.years Date Date from where to start
  #
  # @return Integer number of view counts since `from_date`
  def self.telephone_count(structure, from_date=(Date.today - 10.years))
    return self.generic_count(structure, :actions, from_date, 'telephone')
  end

  # Total website action count
  # @param structure Structure concerned
  # @param from_date=(Date.today - 10.years Date Date from where to start
  #
  # @return Integer number of view counts since `from_date`
  def self.website_count(structure, from_date=(Date.today - 10.years))
    return self.generic_count(structure, :actions, from_date, 'website')
  end

  # Score from the action and conversations statistics
  #
  # @return an Integer between 0 and 4 included.
  def self.score(action, conversations)
    case
    when action == 0
      0
    when action.in?(1..4) && conversations <= 2
      1
    when action.in?(1..4) && conversations > 2
      2
    when action > 5 && conversations <= 2
      2
    when action > 5 && conversations.in?(3..5)
      3
    when action > 5 && conversations > 5
      4
    end
  end

  ######################################################################
  # Private methods and helpers                                        #
  ######################################################################

  private

  # Total metric count from type
  # @param structure Structure concerned
  # @param type The type symbol
  # @param from_date=(Date.today - 10.years Date Date from where to start
  # @param infos=nil Additional informations
  #
  # @return Integer number of view counts since `from_date`
  def self.generic_count(structure, type, from_date=(Date.today - 10.years), infos=nil)
    # Map the documents by their created_at and their user_fingerprint attributes.
    map = %Q{
      function() {
        var key = { user_fingerprint: this.user_fingerprint,
                    created_at:       this.created_at.toDateString() }
        emit(key, { count: 1 })
      }
    }

    # Count the results
    reduce = %Q{
      function(key, values) {
        var result = { count: 0 }
        values.forEach(function(value) {
          result.count += value.count
        });

        return (result);
      }
    }

    values = Metrics.send(type).where(structure_id: structure.id)
                               .not.where(user_fingerprint: nil)
                               .where(:created_at.gt => from_date)
                               .asc(:created_at)

    values = values.where(infos: infos) if infos
    values = values.map_reduce(map, reduce).out(inline: true)

    return values.count
  end

end
