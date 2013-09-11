module ActsAsUnsubscribable

  def self.included(base)
    base.instance_eval do
      include ::ActsAsUnsubscribable::InstanceMethods
    end
  end

  module InstanceMethods
    def access_token
      self.class.create_access_token(self)
    end

    # Verifier based on our application secret
    def self.verifier
      ActiveSupport::MessageVerifier.new(CoursAvenue::Application.config.secret_token)
    end

    # Get an instance from a token
    def self.read_access_token(signature)
      id = verifier.verify(signature)
      self.class.find id
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      nil
    end

    # Class method for token generation
    def self.create_access_token(instance)
      verifier.generate(instance.id)
    end
  end
end
