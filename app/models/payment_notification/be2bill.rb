# encoding: utf-8
class PaymentNotification::Be2bill < PaymentNotification

  private

  def finalize_payment
    params['EXTRADATA'] = JSON.parse(params['EXTRADATA'])

    if params['EXECCODE'] == '0000'
      if params['EXTRADATA']['renew'].present?
        subscription_plan = self.structure.subscription_plan
        subscription_plan.extend_subscription(params)
      else
        subscription_plan_params = { credit_card_number: params[:CARDCODE],
                                     be2bill_alias: params[:ALIAS],
                                     card_validity_date: (params[:CARDVALIDITYDATE] ? Date.strptime(params[:CARDVALIDITYDATE], '%m-%y') : nil),
                                     promotion_code_id: (params[:EXTRADATA].present? ? params[:EXTRADATA]['promotion_code_id'] : nil),
                                     client_ip: params[:CLIENT_IP]
                                   }
        subscription_plan = SubscriptionPlan.subscribe!(params['EXTRADATA']['plan_type'], self.structure, subscription_plan_params)
      end
      # Create order for current payment
      self.structure.orders.create(amount: subscription_plan.amount,
                                   order_id: params['ORDERID'],
                                   promotion_code_id: params['EXTRADATA']['promotion_code_id'],
                                   subscription_plan: subscription_plan)
    else
      if params['EXTRADATA']['renew'].present?
        subscription_plan = self.structure.subscription_plan
        subscription_plan.last_renewal_failed_at = Date.today
        subscription_plan.save
      end
    end
  end

  # Send email when be2bill hits transaction notifications
  def notify_user
    AdminMailer.delay.be2bill_transaction_notifications(self.structure, params)
    if params['EXECCODE'] != '0000'
      Bugsnag.notify(RuntimeError.new("Payment refused"), params)
      AdminMailer.delay.go_premium_fail(self.structure, params)
      if params['EXTRADATA']['renew'].present?
        AdminMailer.delay.subscription_renewal_failed(self.structure, params)
      end
    else
      # Email for admin
      AdminMailer.delay.go_premium(self.structure, params['EXTRADATA']['plan_type'])
    end
  end
end
