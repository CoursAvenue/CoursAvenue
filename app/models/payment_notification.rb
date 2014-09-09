class PaymentNotification < ActiveRecord::Base

  attr_accessible :params, :structure_id, :order_id, :type

  serialize :params

  belongs_to :structure

  after_create :finalize_payment
  after_create :notify_user

  private

  def finalize_payment
    raise Exception.new('You should implement it!')
  end

  def notify_user
    raise Exception.new('You should implement it!')
  end

end
