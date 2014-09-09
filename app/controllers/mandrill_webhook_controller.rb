# encoding: utf-8
class MandrillWebhookController < ApplicationController
  protect_from_forgery only: []

  require 'json'

  # Here is what we get from Mandrill
  # 'mandrill_events' => [{
  #     "event" => "hard_bounce",
  #       "msg" => {
  #                         "ts" => 1365109999,
  #                    "subject" => "This an example webhook message",
  #                      "email" => "example.webhook@mandrillapp.com",
  #                     "sender" => "example.sender@mandrillapp.com",
  #                       "tags" => [
  #             [0] "webhook-example"
  #         ],
  #                      "state" => "bounced",
  #                   "metadata" => {
  #             "user_id" => 111
  #         },
  #                        "_id" => "exampleaaaaaaaaaaaaaaaaaaaaaaaaa",
  #                   "_version" => "exampleaaaaaaaaaaaaaaa",
  #         "bounce_description" => "bad_mailbox",
  #               "bgtools_code" => 10,
  #                       "diag" => "smtp;550 5.1.1 The email account that you tried to reach does not exist. Please try double-checking the recipient's email address for typos or unnecessary spaces."
  #     },
  #       "_id" => "exampleaaaaaaaaaaaaaaaaaaaaaaaaa",
  #        "ts" => 1409834839
  #    }]
  def create
    events = JSON.parse(params['mandrill_events'])
    events.each do |event|
      user = User.where(email: event['msg']['email']).first
      user = Admin.where(email: event['msg']['email']).first                                  if user.nil?
      user = Structure.where(contact_email: event['msg']['email']).first                      if user.nil?
      if user.nil?
        sleeping_structure = Structure.where("meta_data -> 'other_emails' LIKE '%#{event['msg']['email']}%'").first
        return if sleeping_structure.nil?
        sleeping_emails = sleeping_structure.other_emails.split(';')
        sleeping_emails.delete(event['msg']['email'])
        sleeping_structure.other_emails = sleeping_emails.join(',') if sleeping_emails
      end
      next if user.nil?
      user.delivery_email_status = event['event']
      user.save
    end
    render nothing: true
  end

  # When adding a webhook it ensures the url works, here it how we handle it
  def index
    render nothing: true
  end

end
