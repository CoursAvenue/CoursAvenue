require 'spec_helper'
require 'rake'

CoursAvenue::Application.load_tasks

context "scheduler:discovery_pass" do
  describe "five_days_before_renewal" do
    let (:user) { FactoryGirl.create(:user) }
    it "sends an email for pending request the day after" do
      discovery_pass = DiscoveryPass.new(expires_at: 5.days.from_now, user: user)
      discovery_pass.save(validate: false)
      expect {
        Rake::Task['scheduler:discovery_pass:five_days_before_renewal'].invoke
      }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end
end
