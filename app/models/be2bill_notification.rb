# encoding: utf-8
class Be2billNotification < ActiveRecord::Base
  attr_accessible :params, :structure_id, :order_id

  serialize :params

  belongs_to :structure

  after_create :finalize_payment
  after_create :notify_user

  private

  def finalize_payment
    params['EXTRADATA'] = JSON.parse(params['EXTRADATA'])

    if params['EXECCODE'] == '0000'
      if params['EXTRADATA']['renew'].present?
        subscription_plan = self.structure.subscription_plan
      else
        subscription_plan = SubscriptionPlan.subscribe!(params['EXTRADATA']['plan_type'], self.structure, params)
      end
      self.structure.orders.create(amount: subscription_plan.amount,
                                   order_id: params['ORDERID'],
                                   promotion_code_id: params['EXTRADATA']['promotion_code_id'],
                                   subscription_plan: subscription_plan)
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
      AdminMailer.delay.go_premium(self.structure, params['EXTRADATA']['plan_type'])
    end
  end
end
