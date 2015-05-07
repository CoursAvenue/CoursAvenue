class Pro::Structures::SubscriptionsSponsorshipsController < Pro::ProController
  load_and_authorize_resource :structure, find_by: :slug
  before_action :authenticate_pro_admin!, :set_subscription

  def index
    @sponsorships              = @subscription.sponsorships
    @remaining_monthly_credits = @sponsorships.count(&:consumed?)
  end

  def create
    raw_emails = permitted_params[:emails] || ''
    regexp     = Regexp.new(/\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}\b/)

    emails  = raw_emails.scan(regexp).uniq
    message = '<div class="p">' +
      permitted_params[:message].gsub(/\r\n\r\n/, '</div><div class="p">').gsub(/\r\n/, '<br>') +
      '</div>'

    emails.each do |email|
      sponsorship = @subscription.sponsorships.create(sponsored_email: email)
      sponsorship.notify_sponsored(message) if sponsorship and sponsorship.persisted?
    end

    redirect_to pro_structure_subscriptions_sponsorships_path(@structure),
      notice: 'Vos parrainages ont bien été envoyés.'
  end

  def show
  end

  private

  def set_subscription
    @subscription = @structure.subscription
  end

  def permitted_params
    params.permit(:emails, :message)
  end
end
