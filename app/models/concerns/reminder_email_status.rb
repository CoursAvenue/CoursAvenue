# Adds a method to update the last email status of the model (Either structure or user).
# The method `update_last_email_sent_status` is called in {User,Admin}Reminder.
module Concerns
  module ReminderEmailStatus
    extend ActiveSupport::Concern

    included do
      # Update the last email sent fields
      #
      # @param status: The structure status.
      # @param date:   The date the email was sent.
      #
      # @return nil
      def update_last_email_sent_status!(status, date = Time.now)
        update_column :last_email_sent_at, date
        update_column :last_email_sent_status, status
      end
    end
  end
end
