class TestMailer < ActionMailer::Base
  include ::ActionMailerWithTextPart
  include ::Concerns::FormMailer
  include ::EmailActionsHelper
  include ::ActionView::Helpers::TagHelper
  include ::ActionView::Context
  include Roadie::Rails::Automatic

  layout 'email'

  default from: "aliou.diallo2@gmail.com"
  default to:   "aliou.diallo2@gmail.com"

  def mail_action
    token = ReplyToken.create(reply_type: 'conversation',
                                    data: { gmail_action_name: 'Testing' })
    @data = confirm_action(token)

    mail subject: "Mail action"
  end

  # def confirm_action(token)
  #   {
  #     "@context" => "http://schema.org",
  #     "@type"    => "EmailMessage",
  #     "action"   => {
  #       "@type" => "ConfirmAction",
  #       "name"  => token.gmail_action_name,
  #       "handler" => {
  #         "@type" => "HttpActionHandler",
  #         "url"   => reply_token_url(token, subdomain: CoursAvenue::Application::WWW_SUBDOMAIN),
  #       },
  #     },
  #   }
  # end
end
