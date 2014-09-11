# -*- encoding : utf-8 -*-
require 'spec_helper'

describe SubscriptionPlan do
  let(:subject)   { FactoryGirl.build(:subscription_plan) }
  let(:structure) { FactoryGirl.create(:structure_with_admin) }
  let(:subscription_plan) { SubscriptionPlan.subscribe! :monthly, FactoryGirl.create(:structure_with_admin), {} }

  describe '#active?' do
    it 'is not active' do
      subject.stub(:plan_type) { 'monthly' }
      subject.stub(:expires_at) { Date.today - 2.month }
      expect(subject.active?).to be(false)
    end
  end

  describe '#subscribe!' do
    it 'is creates a monthly subscription' do
      subscription_plan = SubscriptionPlan.subscribe! :monthly, structure, {}
      expect(subscription_plan.plan_type).to eq 'monthly'
      expect(subscription_plan.expires_at).to eq Date.today + 1.month
      expect(subscription_plan.active?).to be(true)
    end
  end

  describe '#cancel!' do
    it 'is creates a monthly subscription' do
      structure = FactoryGirl.create :structure_with_admin
      subscription_plan = SubscriptionPlan.subscribe! :monthly, structure, {}
      initial_deliveries_count = ActionMailer::Base.deliveries.count
      subscription_plan.cancel!
      expect(ActionMailer::Base.deliveries.count).to eq (initial_deliveries_count + 2)
      expect(subscription_plan.canceled_at).not_to be_nil
      expect(subscription_plan.canceled?).to be(true)
    end
  end

  describe '#reactivate' do
    it 'removes canceled_at' do
      subscription_plan.canceled_at = Time.now
      subscription_plan.reactivate!
      expect(subscription_plan.canceled_at).to eq nil
    end
  end

  describe '#subscribe_yearly!' do
    it 'is subscribes to premium' do
      subscription_plan = SubscriptionPlan.subscribe! :yearly, structure, {}
      expect(subscription_plan.plan_type).to eq 'yearly'
      expect(subscription_plan.expires_at).to eq Date.today + 1.year
      expect(subscription_plan.active?).to be(true)
    end
  end

  describe '#amount' do
    it 'gives price regarding plan type' do
      plan_types = ['yearly', 'monthly', 'three_months']
      plan_types.each do |plan_type|
        subscription_plan = SubscriptionPlan.subscribe! plan_type, structure, {}
        expect(subscription_plan.amount).to eq SubscriptionPlan::PLAN_TYPE_PRICES[plan_type]
      end
    end
  end

  describe '#next_amount' do
    it 'returns monthly amount' do
      plan_types =  {'monthly'      => 'monthly',
                     'yearly'       => 'yearly',
                     'three_months' => 'monthly'}
      plan_types.each do |plan_type, expected_plan_type|
        subscription_plan = SubscriptionPlan.subscribe! plan_type, structure, {}
        expect(subscription_plan.next_amount).to eq SubscriptionPlan::PLAN_TYPE_PRICES[expected_plan_type]
      end
    end
  end

  describe '#amount_for_be2bill' do
    it 'gives price regarding plan type multiplied by 100' do
      plan_types = ['yearly', 'monthly', 'three_months']
      plan_types.each do |plan_type|
        subscription_plan = SubscriptionPlan.subscribe! plan_type, structure, {}
        expect(subscription_plan.amount_for_be2bill).to eq SubscriptionPlan::PLAN_TYPE_PRICES[plan_type] * 100
      end
    end
  end

  describe '#canceled?' do
    it 'is canceled' do
      subscription_plan = SubscriptionPlan.subscribe! 'yearly', structure, {}
      subscription_plan.stub(:canceled_at) { Time.now }
      expect(subscription_plan.canceled?).to be(true)
    end
  end

  describe '#active?' do
    context 'canceled' do
      it 'is not active' do
        subscription_plan = SubscriptionPlan.subscribe! 'yearly', structure, {}
        subscription_plan.stub(:canceled_at) { Time.now }
        expect(subscription_plan.active?).to eq false
      end
    end

    context 'expired' do
      it 'is not active' do
        subscription_plan = SubscriptionPlan.subscribe! 'yearly', structure, {}
        subscription_plan.stub(:expires_at) { Date.yesterday }
        expect(subscription_plan.active?).to be(false)
      end
    end
    it 'is active' do
      subscription_plan = SubscriptionPlan.subscribe! 'yearly', structure, {}
      subscription_plan.stub(:expires_at) { Date.tomorrow }
      expect(subscription_plan.active?).to be(true)
    end
  end

  describe '#frequency' do
    it 'returns monthly' do
      plan_types =  {'monthly'      => 'monthly',
                     'yearly'       => 'yearly',
                     'three_months' => 'monthly'}
      plan_types.each do |plan_type, expected_plan_type|
        subscription_plan = SubscriptionPlan.subscribe! plan_type, structure, {}
        expect(subscription_plan.frequency).to eq SubscriptionPlan::PLAN_TYPE_FREQUENCY[expected_plan_type]
      end
    end
  end

  describe '#renew!' do
    it 'runs renew renew_with_be2bill!' do
      subscription_plan = SubscriptionPlan.new
      subscription_plan.stub(:payed_through_be2bill?) { true }
      subscription_plan.stub(:payed_through_paypal?) { false }
      subscription_plan.stub(:renew_with_be2bill!) { 'HEY!' }
      expect(subscription_plan.renew!).to eq 'HEY!'
    end

    it 'does not run renew renew_with_be2bill!' do
      subscription_plan = SubscriptionPlan.new
      subscription_plan.stub(:payed_through_be2bill?) { false }
      subscription_plan.stub(:payed_through_paypal?) { true }
      subscription_plan.stub(:renew_with_be2bill!) { 'HEY!' }
      expect(subscription_plan.renew!).not_to eq 'HEY!'
    end
  end

  describe '#payed_through_be2bill?' do
    it 'returns monthly' do
      subscription_plan = SubscriptionPlan.new
      subscription_plan.stub(:be2bill_alias) { 'lorem' }
      expect(subscription_plan.payed_through_be2bill?).to be_truthy
      expect(subscription_plan.payed_through_paypal?).to be_falsy
    end
  end

  describe '#payed_through_paypal?' do
    it 'returns monthly' do
      subscription_plan = SubscriptionPlan.new
      subscription_plan.stub(:paypal_payer_id) { 'lorem' }
      expect(subscription_plan.payed_through_paypal?).to be_truthy
      expect(subscription_plan.payed_through_be2bill?).to be_falsy
    end
  end

end
