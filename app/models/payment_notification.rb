class PaymentNotification < ActiveRecord::Base

  attr_accessible :params, :structure_id, :order_id, :type, :user_id, :product_type

  PRODUCT_TYPES = %w(premium_account)

  serialize :params

  belongs_to :structure
  belongs_to :user

  after_create :finalize_payment
  after_create :notify_user

  # Is the payment succeeded?
  #
  # @return Boolean
  def payment_succeeded?
    false
  end

  # Is the payment a renewal?
  #
  # @return Boolean
  def is_a_renewal?
    false
  end

  private

  #
  # Finalize the payment by creating the correct stuff in the Database, etc.
  #
  # @return nil
  def finalize_payment
    finalize_payment_for_premium_account
  end

  def finalize_payment_for_premium_account
    raise Exception.new('You should implement it!')
  end


  # Send email when be2bill hits transaction notifications
  def notify_user
    if self.payment_succeeded?
      # Email for admin
      SuperAdminMailer.delay.go_premium(self.structure, self.structure.subscription_plan.plan_type) unless self.is_a_renewal?
    else
      Bugsnag.notify(RuntimeError.new("Payment refused"), params)
      if self.is_a_renewal?
        AdminMailer.delay.subscription_renewal_failed(self.structure)
      end
    end
  end

end
