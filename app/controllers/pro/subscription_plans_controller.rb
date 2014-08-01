# encoding: utf-8
class Pro::SubscriptionPlansController < Pro::ProController
  before_action :authenticate_pro_super_admin!

  def index
    @orders = Order.all

    dates = (2.month.ago.to_date..Date.today).step
    @orders_progression = {}
    dates.each do |date|
      @orders_progression[date] = Order.where( Order.arel_table[:created_at].lt(date) ).count
    end

  end
end
