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

  def premium_tracking
    @subscriptions = SubscriptionPlan.where(canceled_at: nil)
  end

  def stat_info
    subscription = SubscriptionPlan.find(params[:id])
    data = { impressions:   Statistic.impression_count(subscription.structure),
             views:         Statistic.view_count(subscription.structure),
             actions:       Statistic.action_count(subscription.structure),
             conversations: subscription.structure.main_contact.mailbox.conversations.where(mailboxer_label_id: Mailboxer::Label::INFORMATION.id).count,
             telephone:     Statistic.telephone_count(subscription.structure),
             website:       Statistic.website_count(subscription.structure) }
    respond_to do |format|
      format.json { render json: data }
    end
  end
end
