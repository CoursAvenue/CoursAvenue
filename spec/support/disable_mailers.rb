RSpec.configure do |config|
  MAILER_CLASSES = [AdminMailer, TestMailer, SuperAdminMailer, UserMailer,
                    ParticipationRequestMailer, SubscriptionsSponsorshipMailer]

  config.before(:each) do
    unless self.to_s.include? 'Mailer' or self.to_s.include? 'Task'
      MAILER_CLASSES.each do |mailer_class|
        # Because first methods shown are public methods, and all methods after `:mail` methods
        # are not needed
        mailer_class.instance_methods.split(:mail).first.each do |method_name|
          allow(mailer_class).to receive(method_name) { double(mailer_class.to_s, deliver: true) }
        end
      end
    end
  end

  config.before(:example, with_mail: true) do
    MAILER_CLASSES.each do |mailer_class|
      mailer_class.instance_methods.split(:mail).first.each do |method_name|
        allow(mailer_class).to receive(method_name).and_call_original
      end
    end
  end

end
