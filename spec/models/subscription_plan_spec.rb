# -*- encoding : utf-8 -*-
require 'spec_helper'

describe SubscriptionPlan do
  let(:subject)   { FactoryGirl.build(:subscription_plan) }
  let(:structure) { FactoryGirl.create(:structure) }

  describe '#active?' do
    it 'is not active' do
      subject.stub(:plan_type) { 'monthly' }
      subject.stub(:expires_at) { Date.today - 2.month }
      expect(subject.active?).to be_false
    end
  end

  describe '#subscribe!' do
    it 'is creates a monthly subscription' do
      subscription_plan = SubscriptionPlan.subscribe! :monthly, structure, {}
      expect(subscription_plan.plan_type).to eq 'monthly'
      expect(subscription_plan.expires_at).to eq Date.today + 1.month
      expect(subscription_plan.active?).to be_true
    end
  end

  describe '#subscribe_yearly!' do
    it 'is subscribes to premium' do
      subscription_plan = SubscriptionPlan.subscribe! :yearly, structure, {}
      expect(subscription_plan.plan_type).to eq 'yearly'
      expect(subscription_plan.expires_at).to eq Date.today + 1.year
      expect(subscription_plan.active?).to be_true
    end
  end
end
