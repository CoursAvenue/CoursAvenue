require 'google/api_client'

class Analytic::Client
  APPLICATON_NAME    = 'CoursAvenue'
  APPLICATON_VERSION = '1'
  EXPIRES_IN         = 60 * 60
  SCOPE              = "https://www.googleapis.com/auth/analytics.readonly"

  GOOGLE_AUTHORIZE_URL = 'https://accounts.google.com/o/oauth2/auth'
  GOOGLE_TOKEN_URL     = 'https://accounts.google.com/o/oauth2/token'

  def initialize
    refresh!
  end

  # Whether the API token has expired.
  #
  # @return a Boolean.
  def expired?
    @user.nil? || @user.access_token.expired?
  end

  # Get the Legato::User object from the token.
  #
  # @return a Legato::User.
  def user
    if expired?
      refresh!
      @user = ::Legato::User.new(@token)
    else
      @user
    end
  end

  private

  # Refresh the API token.
  #
  # @return the new Token.
  def refresh!
    google_client = ::Google::APIClient.new(application_name:    APPLICATON_NAME,
                                            application_version: APPLICATON_VERSION)

    key_path = ::Rails.root.join('config','analytics_key_file.p12').to_s
    key = ::Google::APIClient::PKCS12.load_key(key_path, ENV['GOOGLE_ANALYTICS_SERVICE_SECRET_KEY'])
    service_account = ::Google::APIClient::JWTAsserter.new(ENV['GOOGLE_ANALYTICS_SERVICE_EMAIL'], SCOPE, key)

    google_client.authorization = service_account.authorize

    oauth_client = ::OAuth2::Client.new('', '', {
      authorize_url: GOOGLE_AUTHORIZE_URL,
      token_url:     GOOGLE_TOKEN_URL
    })

    @token = ::OAuth2::AccessToken.new(oauth_client, google_client.authorization.access_token, expires_in: EXPIRES_IN)
  end
end
