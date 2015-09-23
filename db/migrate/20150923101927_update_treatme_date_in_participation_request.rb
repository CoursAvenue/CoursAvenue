class UpdateTreatmeDateInParticipationRequest < ActiveRecord::Migration
  def up
    bar = ProgressBar.new(ParticipationRequest.count)
    ParticipationRequest.find_each do |pr|
      bar.increment!
      if pr.conversation.present?
        message = pr.conversation.messages.where(sender_type: 'Admin').first
        pr.update_attribute(:treated_at, message.created_at) if message.present?
      end
    end
  end

  def down
    ParticipationRequest.update_all(treated_at: nil)
  end
end
