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
  def process
    events = JSON.parse(params['mandrill_events'])
    events.each do |event|
      user = User.where(email: event['msg']['email']).first
      if user.nil?
        user = Admin.where(email: event['msg']['email']).first
      end
      next if user.nil?
      user.delivery_email_status = event['event']
      user.save
    end
  end

end
