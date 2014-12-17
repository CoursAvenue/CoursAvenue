class TestMailer < ActionMailer::Base
  default from: "aliou.diallo2@gmail.com"
  default to:   "aliou.diallo2@gmail.com"

  def mail_action
    token       = ReplyToken.create(reply_type: 'conversation',
                                   data: { gmail_action_name: 'Testing' })
    @data = confirm_action(token)

    mail subject: "Mail action"
  end

  def confirm_action(token)
    helper_data = {
      "@context" => "http://schema.org",
      "@type" => "EmailMessage",
      "action" => {
        "@type" => "ConfirmAction",
        "name" => "Confirm registration",
        "handler" => {
          "@type" => "HttpActionHandler",
          "url" => "http://google.fr",
        },
      },
    }
  end
end
