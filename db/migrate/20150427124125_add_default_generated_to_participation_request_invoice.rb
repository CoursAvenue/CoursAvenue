class AddDefaultGeneratedToParticipationRequestInvoice < ActiveRecord::Migration
  def change
    change_column_default :participation_requests, :generate, false
  end
end
