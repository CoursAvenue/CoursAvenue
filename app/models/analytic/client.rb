require 'google/api_client'

# Docs:
# * <https://github.com/tpitale/legato/wiki/OAuth2-and-Google>
# * <https://github.com/tpitale/legato/wiki/Quick-Start>
# * <https://gist.github.com/joost/5344705>
class Analytic::Client
  APPLICATON_NAME    = 'CoursAvenue'
  APPLICATON_VERSION = '1'
  EXPIRES_IN         = 60 * 60
  SCOPE              = "https://www.googleapis.com/auth/analytics.readonly"

  GOOGLE_AUTHORIZE_URL = 'https://accounts.google.com/o/oauth2/auth'
  GOOGLE_TOKEN_URL     = 'https://accounts.google.com/o/oauth2/token'

  def initialize
    @google_client = ::Google::APIClient.new(application_name:    APPLICATON_NAME,
                                             application_version: APPLICATON_VERSION)

    @key_path = ::Rails.root.join('config','analytics_key_file.p12').to_s
    @key = ::Google::APIClient::PKCS12.load_key(@key_path, ENV['GOOGLE_ANALYTICS_SERVICE_SECRET_KEY'])
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

  # Retrieve all the metrics for the supplied structure.
  #
  # @param structure_id The structure id
  # @param start_date   The start date, by default 15 days ago.
  # @param end_date     The end date, by defautl yesterday.
  #
  # @return an OpenStruct with the data.
  def hits(structure_id, start_date = 15.days.ago, end_date = 1.day.ago)
    Analytic::Hit.results(profile, start_date: start_date, end_date: end_date).
      for_structure(structure_id).to_a
  end

  # Retrieve the Metrics of type action
  #
  # @param structure_id The structure id
  # @param start_date   The start date, by default 15 days ago.
  # @param end_date     The end date, by defautl yesterday.
  #
  # @return an OpenStruct with the data.
  def actions(structure_id, start_date = 15.days.ago, end_date = 1.day.ago)
    Analytic::Action.results(profile, start_date: start_date, end_date: end_date).
      for_structure(structure_id).to_a
  end

  # Retrieve the Metrics of type view
  #
  # @param structure_id The structure id
  # @param start_date   The start date, by default 15 days ago.
  # @param end_date     The end date, by defautl yesterday.
  #
  # @return an OpenStruct with the data.
  def views(structure_id, start_date = 15.days.ago, end_date = 1.day.ago)
    Analytic::View.results(profile, start_date: start_date, end_date: end_date).
      for_structure(structure_id).to_a
  end

  # Retrieve the Metrics of type impression
  #
  # @param structure_id The structure id
  # @param start_date   The start date, by default 15 days ago.
  # @param end_date     The end date, by defautl yesterday.
  #
  # @return an OpenStruct with the data.
  def impressions(structure_id, start_date = 15.days.ago, end_date = 1.day.ago)
    Analytic::Impression.results(profile, start_date: start_date, end_date: end_date).
      for_structure(structure_id).to_a
  end

  private

  # Refresh the API token.
  #
  # @return the new Token.
  def refresh!
    service_account = ::Google::APIClient::JWTAsserter.new(ENV['GOOGLE_ANALYTICS_SERVICE_EMAIL'], SCOPE, @key)

    @google_client.authorization = service_account.authorize

    oauth_client = ::OAuth2::Client.new('', '', {
      authorize_url: GOOGLE_AUTHORIZE_URL,
      token_url:     GOOGLE_TOKEN_URL
    })

    @token = ::OAuth2::AccessToken.new(oauth_client, @google_client.authorization.access_token, expires_in: EXPIRES_IN)
  end

  # Get the profile to run the query on. By default we get the first one, which should be
  # 'CoursAvenue'.
  #
  # @return a Legato::Profile
  def profile(name = 'CoursAvenue')
    @profile ||= user.profiles.first
    # @profile ||= user.profiles.find do |profile|
    #   profile.name == name
    # end
  end
end
