module EmailActionsHelper
  # Public: Generate the email markup to have an action in GMail.
  def confirm_action(token)
    {
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
  end
end
