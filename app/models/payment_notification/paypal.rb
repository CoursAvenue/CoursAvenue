class PaymentNotification::Paypal < PaymentNotification
  include Rails.application.routes.url_helpers

  def payment_succeeded?
    return (params['PayerID'].present? and params['PayerID'].present?)
  end

  def was_a_renewal?
    false
  end

  private

  def finalize_payment
    response = request_first_paypal_payment
    if response.approved? and response.completed?
      paypal_profile_id = create_paypal_recurring_profile.profile_id
      self.params['paypal_recurring_profile_token'] = paypal_profile_id
      self.save
      subscription_plan_params = { paypal_token: params['token'], paypal_recurring_profile_token: paypal_profile_id, paypal_payer_id: params['PayerID']  }
      subscription_plan        = SubscriptionPlan.subscribe!(params['plan_type'], self.structure, subscription_plan_params)
      self.structure.orders.create(amount: subscription_plan.amount,
                                   order_id: Order.next_order_id_for(self.structure),
                                   subscription_plan: subscription_plan)

    end
  end

  def request_first_paypal_payment
    PayPal::Recurring.new({
      :token       => params['token'],
      :payer_id    => params['PayerID'],
      :amount      => SubscriptionPlan::PLAN_TYPE_PRICES[params['plan_type']].to_f.to_s,
      :currency    => "EUR",
      :description => "CoursAvenue Premium - #{SubscriptionPlan::PLAN_TYPE_DESCRIPTION[params['plan_type']]}"
    }).request_payment
  end

  def create_paypal_recurring_profile
    PayPal::Recurring.new({
        :amount      => SubscriptionPlan::PLAN_TYPE_PRICES[params['plan_type']].to_f.to_s,
        :currency    => "EUR",
        :description => "CoursAvenue Premium - #{SubscriptionPlan::PLAN_TYPE_DESCRIPTION[params['plan_type']]}",
        # :ipn_url     => paypal_confirmation_pro_payments_url(structure_id: @structure.id, plan_type: params['plan_type'], ipn: true, host: 'coursavenue.com'),
        :frequency   => 1,
        :token       => params['token'],
        :period      => :monthly,
        :reference   => Order.next_order_id_for(self.structure),
        :payer_id    => params['PayerID'],
        :start_at    => Time.now,
        :failed      => 1,
        :outstanding => :next_billing
      }).create_recurring_profile
  end
end
