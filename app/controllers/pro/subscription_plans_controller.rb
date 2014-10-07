# encoding: utf-8
class Pro::SubscriptionPlansController < Pro::ProController
  before_action :authenticate_pro_super_admin!
  before_action :set_subscription_plan, only: [:stat_info, :update]

  def index
    @orders = Order::Premium.all

    # @orders_per_month  = Order::Premium.order("DATE_TRUNC('month', created_at) ASC").group("DATE_TRUNC('month', created_at)").count
    @orders_per_month = {}
    (Date.new(2014, 6)..Date.today + 1.month).select {|d| d.day == 1}.map {|d| d - 1}.drop(1).each do |end_of_month|
      @orders_per_month[end_of_month] = SubscriptionPlan.where(SubscriptionPlan.arel_table[:expires_at].gteq(end_of_month - 1.month).and(
                                                               SubscriptionPlan.arel_table[:created_at].lteq(end_of_month))).count
    end
  end

  def premium_tracking
    @subscriptions = SubscriptionPlan.where(SubscriptionPlan.arel_table[:expires_at].gt(Date.today))
    @current_tab = 'premium_tracking'
  end

  def unsubscribed_tracking
    @subscriptions = SubscriptionPlan.where(SubscriptionPlan.arel_table[:expires_at].lt(Date.today))
    @current_tab = 'unsubscribed_tracking'

    render 'premium_tracking'
  end

  # Fetches statistics for the related SubscriptionPlan
  #
  # @return The statistics for the related SubscriptionPlan as JSON.
  def stat_info
    since_date = @subscription.renewed_at.present? ? @subscription.renewed_at : @subscription.created_at.to_date

    stats = { impressions:        Metric.impression_count(@subscription.structure, since_date),
              views:              Metric.view_count(@subscription.structure, since_date),
              actions:            Metric.action_count(@subscription.structure, since_date),
              telephone:          Metric.telephone_count(@subscription.structure, since_date),
              website:            Metric.website_count(@subscription.structure, since_date),
              conversations:      @subscription.structure.main_contact.mailbox.conversations.where(mailboxer_label_id: Mailboxer::Label::INFORMATION.id).where(Mailboxer::Conversation.arel_table[:created_at].gt(since_date)).count,

              impressions_full:   Metric.impression_count(@subscription.structure),
              views_full:         Metric.view_count(@subscription.structure),
              actions_full:       Metric.action_count(@subscription.structure),
              telephone_full:     Metric.telephone_count(@subscription.structure),
              website_full:       Metric.website_count(@subscription.structure),
              conversations_full: @subscription.structure.main_contact.mailbox.conversations.where(mailboxer_label_id: Mailboxer::Label::INFORMATION.id).count }

    stats[:color] = label_color(stats)

    respond_to do |format|
      format.json { render json: stats }
    end
  end

  # Updates the metadata from the related SubscriptionPlan
  #
  # @return
  def update
    respond_to do |format|
      if @subscription.update_attributes(params[:subscription_plan])
        format.js { render nothing: true}
      else
        format.js { render json: @subscription.errors, status: :unprocessable_entity }
      end
    end
  end

  # Create a dump of the Subscription in a queue
  #
  # @return nil
  def download
    SubscriptionPlanExport.create
    redirect_to premium_tracking_pro_subscription_plans_path, notice: 'Le fichier est en cours de création.'
  end

  private

  # Deduce the label index from the statistics score
  #
  # @return an Integer between 0 and 4 included.
  def index_color(stats, action=:actions, conversations=:conversations)
    Metric.score(stats[action], stats[conversations])
  end

  # Return the color depending on the statistics score
  #
  # @return a String that is the label color.
  def label_color(stats, action=:actions, conversations=:conversations)
    ['red', 'orange', 'yellow', 'green-light', 'green'][index_color(stats, action, conversations)]
  end

  # Set the current SubscriptionPlan
  #
  # @return The current SubscriptionPlan
  def set_subscription_plan
    @subscription = SubscriptionPlan.find(params[:id])
  end
end
