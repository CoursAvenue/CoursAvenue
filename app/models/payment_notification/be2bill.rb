# encoding: utf-8
class PaymentNotification::Be2bill < PaymentNotification

  def payment_succeeded?
    params['EXECCODE'] == '0000'
  end

  def is_a_renewal?
    params['EXTRADATA']['renew'].present?
  end

  private

  # Purchased has been done by Be2Bill, let's check the response and deal with it
  #
  # @return nil
  def finalize_payment_for_discovery_pass
    params['EXTRADATA'] = JSON.parse(params['EXTRADATA']) unless params['EXTRADATA'].is_a? Hash

    if payment_succeeded?
      if is_a_renewal?
        discovery_pass = self.user.discovery_pass
        discovery_pass.extend_be2bill_subscription(params)
      else
        discovery_pass_params = { credit_card_number: params['CARDCODE'],
                                  be2bill_alias:      params['ALIAS'],
                                  card_validity_date: (params['CARDVALIDITYDATE'] ? Date.strptime(params['CARDVALIDITYDATE'], '%m-%y') : nil),
                                  client_ip:          params['CLIENT_IP']
                                }
        discovery_pass = self.user.discovery_passes.create(discovery_pass_params)
      end
      self.user.orders.create(amount: discovery_pass.amount,
                              order_id: params['ORDERID'],
                              discovery_pass: discovery_pass)

    else
      if params['EXTRADATA']['renew'].present?
        discovery_pass = self.user.discovery_pass
        discovery_pass.last_renewal_failed_at = Date.today
        discovery_pass.save
      end
    end
  end

  def finalize_payment_for_premium_account
    params['EXTRADATA'] = JSON.parse(params['EXTRADATA']) unless params['EXTRADATA'].is_a? Hash

    if payment_succeeded?
      if is_a_renewal?
        subscription_plan = self.structure.subscription_plan
        subscription_plan.extend_be2bill_subscription(params)
      else
        subscription_plan_params = { credit_card_number: params['CARDCODE'],
                                     be2bill_alias: params['ALIAS'],
                                     card_validity_date: (params['CARDVALIDITYDATE'] ? Date.strptime(params['CARDVALIDITYDATE'], '%m-%y') : nil),
                                     promotion_code_id: (params['EXTRADATA'].present? ? params['EXTRADATA']['promotion_code_id'] : nil),
                                     client_ip: params['CLIENT_IP']
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
end
