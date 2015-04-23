# Genereate coverage exepct on CI.
if !ENV['CI']
  require 'simplecov'
  SimpleCov.start 'rails'
end

RSpec.configure do |config|
  # Print the 10 slowest examples and example groups at the
  # end of the spec run, to help surface which specs are running
  # particularly slow.
  # This never runs on CI.
  if !ENV['CI'] and !config.files_to_run.one?
    config.profile_examples = 10
  end

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  # config.order = :random

  # Seed global randomization in this process using the `--seed` CLI option.
  # Setting this allows you to use `--seed` to deterministically reproduce
  # test failures related to randomization by passing the same `--seed` value
  # as the one that triggered the failure.
  # Kernel.srand config.seed

  config.raise_errors_for_deprecations!

  RSpec.configure do |config|
    config.before(:each) do
      unless self.to_s.include? 'Mailer' or self.to_s.include? 'Task'
        [AdminMailer, TestMailer,
          SuperAdminMailer, UserMailer, ParticipationRequestMailer].each do |mailer_class|
          # Because first methods shown are public methods, and all methods after `:mail` methods are not needed
          mailer_class.instance_methods.split(:mail).first.each do |method_name|
            allow(mailer_class).to receive(method_name) { double(mailer_class.to_s, deliver: true) }
          end
        end
      end
    end
  end
end
