module EmailActionsHelper
  # Public: Generate the email markup to have an action in GMail.
  def confirm_action(token)
    helper_data = {
      "@context" => "http://schema.org",
      "@type" => "EmailMessage",
      "action" => {
        "@type" => "ConfirmAction",
        "name" => token.gmail_action_name,
        "handler" => {
          "@type" => "HttpActionHandler",
          "url" => reply_token_url(token),
        },
      },
    }

    content_tag :script, type: 'application/ld+json' do
      JSON.pretty_generate(helper_data).html_safe
    end
  end
end
