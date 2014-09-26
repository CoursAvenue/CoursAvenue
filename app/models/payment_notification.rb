class PaymentNotification < ActiveRecord::Base

  attr_accessible :params, :structure_id, :order_id, :type

  serialize :params

  belongs_to :structure

  after_create :finalize_payment
  after_create :notify_user

  def payment_succeeded?
    false
  end

  def is_a_renewal?
    false
  end

  private

  def finalize_payment
    raise Exception.new('You should implement it!')
  end

  # Send email when be2bill hits transaction notifications
  def notify_user
    SuperAdminMailer.delay.be2bill_transaction_notifications(self.structure, params)

    if self.payment_succeeded?
      # Email for admin
      SuperAdminMailer.delay.go_premium(self.structure, self.structure.subscription_plan.plan_type) unless self.is_a_renewal?
    else
      Bugsnag.notify(RuntimeError.new("Payment refused"), params)
      SuperAdminMailer.delay.go_premium_fail(self.structure, params)
      if self.is_a_renewal?
        AdminMailer.delay.subscription_renewal_failed(self.structure)
      end
    end
  end

end
