class ChangeDeclinedStatusToCancelForPrs < ActiveRecord::Migration
  def change
    ParticipationRequest.where(state: 'declined').update_all state: 'canceled'
  end
end
