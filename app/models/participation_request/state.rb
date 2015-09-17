class ParticipationRequest::State < ActiveRecord::Base
  POSSIBLE_STATES = %w(pending treated accepted canceled)

  include Concerns::HstoreHelper

  belongs_to :participation_request

  delegate :structure, :user, to: :participation_request, prefix: false

  store_accessor :metadata, :events

  after_create :add_creation_event

  # TODO: Refactor this using `define_method`.

  # The state is pending by default, thanks to the database.
  def pending?
    self.state == 'pending'
  end

  def accept!
    self.state = 'accepted'
    self.accepted_at = DateTime.current

    add_event({ state: 'accepted', date: accepted_at.to_i })

    save
  end

  def accepted?
    self.state == 'accepted'
  end

  def cancel!
    self.state = 'canceled'
    self.canceled_at = DateTime.current

    add_event({ state: 'canceled', date: accepted_at.to_i })

    save
  end

  def canceled?
    self.state == 'canceled'
  end

  def treat!(method = 'infos')
    self.state = 'treated'
    self.treated_at = DateTime.current
    self.treat_method = method

    add_event({ state: 'treated', date: accepted_at.to_i })

    save
  end

  def treated?
    self.state == 'treated'
  end

  def get_events
    return [] if self.events.nil?

    JSON.parse(self.events)
  end

  private

  def add_event(event)
    _events = get_events
    _events << event

    self.events = JSON.generate(_events)
    save
  end

  def add_creation_event
    add_event({ state: 'created', date: created_at.to_i })
  end
end
