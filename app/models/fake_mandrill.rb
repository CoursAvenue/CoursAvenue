module FakeMandrill
  class Client
    def initialize
      Rails.logger.debug "[FakeMandrill][initialize] Initialized."
    end

    def messages
      @client ||= MessagesClient.new
    end
  end

  class MessagesClient
    REJECT_REASONS = ["hard-bounce", "soft-bounce", "spam", "unsub", "custom", "invalid-sender", "invalid", "test-mode-limit", "rule"]
    STATUSES       = %w(sent queued scheduled rejected invalid)

    def send(message, async = false, ip_pool = 'Main Pool', send_at = nil)
      Rails.logger.debug "[FakeMandrill][messages][send] sending message with following informations:"
      Rails.logger.debug "[FakeMandrill][messages][send]   subject:    #{message[:subject]}"
      Rails.logger.debug "[FakeMandrill][messages][send]   from_email: #{message[:from_email]}"
      Rails.logger.debug "[FakeMandrill][messages][send]   from_name:  #{message[:from_name]}"

      # Send the newsletter using a regular mailer. This should be intercepted.
      newsletter = Newsletter.friendly.find message[:metadata][0][:newsletter]
      NewsletterSender.send_preview(newsletter, newsletter.reply_to)

      # Mock the response.
      res = newsletter.recipients.map do |recipient|
        {
          _id:           newsletter.id,
          email:         recipient.email,
          status:        STATUSES.sample,
          reject_reason: REJECT_REASONS.sample,
        }
      end
    end

    def info(message_id)
      Rails.logger.debug "[FakeMandrill][messages][info] info from email with id: #{message_id}"

      {
        _id: message_id
      }
    end
  end
end
