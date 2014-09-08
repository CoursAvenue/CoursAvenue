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
    @subscriptions = SubscriptionPlan.all
  end

  def stat_info
    subscription = SubscriptionPlan.find(params[:id])
    data = { impressions:   subscription.structure.statistics.impressions.count,
             views:         subscription.structure.statistics.views.count,
             actions:       subscription.structure.statistics.actions.count,
             conversations: subscription.structure.main_contact.mailbox.conversations.where(mailboxer_label_id: Mailboxer::Label::INFORMATION.id).count,
             telephone:     subscription.structure.statistics.actions.where(infos: 'telephone').count,
             website:       subscription.structure.statistics.actions.where(infos: 'website').count }
    respond_to do |format|
      format.json { render json: data }
    end
  end
end
