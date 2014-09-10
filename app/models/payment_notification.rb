class PaymentNotification < ActiveRecord::Base

  attr_accessible :params, :structure_id, :order_id, :type

  serialize :params

  belongs_to :structure

  after_create :finalize_payment
  after_create :notify_user

  def payment_succeeded?
    false
  end

  def was_a_renewal?
    false
  end

  private

  def finalize_payment
    raise Exception.new('You should implement it!')
  end

  # Send email when be2bill hits transaction notifications
  def notify_user
    AdminMailer.delay.be2bill_transaction_notifications(self.structure, params)

    if self.payment_succeeded?
      # Email for admin
      AdminMailer.delay.go_premium(self.structure, self.structure.subscription_plan.plan_type)
    else
      Bugsnag.notify(RuntimeError.new("Payment refused"), params)
      AdminMailer.delay.go_premium_fail(self.structure, params)
      if self.was_a_renewal?
        AdminMailer.delay.subscription_renewal_failed(self.structure)
      end
    end
  end

end
