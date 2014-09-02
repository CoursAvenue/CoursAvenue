# encoding: utf-8
class Pro::SubscriptionPlansController < Pro::ProController
  before_action :authenticate_pro_super_admin!

  def index
    @orders = Order.all

    # @orders_per_month  = Order.order("DATE_TRUNC('month', created_at) ASC").group("DATE_TRUNC('month', created_at)").count
    @orders_per_month = {}
    (Date.new(2014, 6)..Date.today + 1.month).select {|d| d.day == 1}.map {|d| d - 1}.drop(1).each do |end_of_month|
      @orders_per_month[end_of_month] = SubscriptionPlan.where(SubscriptionPlan.arel_table[:expires_at].gteq(end_of_month - 1.month).and(
                                                               SubscriptionPlan.arel_table[:created_at].lteq(end_of_month))).count
    end

    # dates = (2.month.ago.to_date..Date.today).step
    # @orders_progression = {}
    # dates.each do |date|
    #   @orders_progression[date] = Order.where( Order.arel_table[:created_at].lt(date) ).count
    # end

  end
end
