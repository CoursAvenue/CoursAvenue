module Concerns
  module HasRandomToken
    extend ActiveSupport::Concern
    included do
      extend FriendlyId

      friendly_id :token, use: [:finders]

      ######################################################################
      # Callbacks                                                          #
      ######################################################################

      before_validation :create_token

      private

      # Creates an unique token.
      #
      # @return self
      def create_token
        if self.token.nil?
          self.token = loop do
            random_token = SecureRandom.urlsafe_base64
            break random_token unless self.class.exists?(token: random_token)
          end
        end
      end
    end
  end
end
