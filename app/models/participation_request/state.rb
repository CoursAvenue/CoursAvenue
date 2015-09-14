class ParticipationRequest::State < ActiveRecord::Base
  include Concerns::HstoreHelper

  belongs_to :participation_request

  delegate :structure, :user, to: :participation_request, prefix: false

  store_accessor :metadata, :events

  # TODO: Refactor this using `define_method`.

  # The state is pending by default, thanks to the database.
  def pending?
    self.state == 'pending'
  end

  def accept!
    self.state = 'accepted'
    self.accepted_at = DateTime.current

    add_event({ state: 'state', date: accepted_at })

    save
  end

  def accepted?
    self.state == 'accepted'
  end

  def cancel!
    self.state = 'canceled'
    self.canceled_at = DateTime.current

    add_event({ state: 'state', date: accepted_at })

    save
  end

  def canceled?
    self.state == 'canceled'
  end

  def treat!
    self.state = 'treated'
    self.treated_at = DateTime.current

    add_event({ state: 'state', date: accepted_at })

    save
  end

  def treated?
    self.state == 'treated'
  end

  def get_events
  end

  private

  def add_event(event)
  end
end
