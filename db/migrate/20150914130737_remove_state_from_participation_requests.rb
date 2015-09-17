class RemoveStateFromParticipationRequests < ActiveRecord::Migration
  def up
    bar = ProgressBar.new(ParticipationRequest.count)

    ParticipationRequest.find_each do |pr|
      pr_state = (pr.participation_request_state || pr.create_participation_request_state)
      case pr.state
      when 'accepted'
        pr_state.accept!
      when 'canceled'
        pr_state.cancel!
      when 'treated'
        pr_state.treat!
      when 'pending'
        # No op
      end

      bar.increment!
    end
    remove_column :participation_requests, :state
  end

  def down
    add_column :participation_requests, :state, :string

    bar = ProgressBar.new(ParticipationRequest::State.count)
    ParticipationRequest::State.find_each do |prs|
      pr = prs.participation_request
      pr.state = prs.state
      pr.save

      bar.increment!
    end
  end
end
