class Pro::SubscriptionsInvoicesController < Pro::ProController
  before_action :authenticate_pro_super_admin!

  def index
    @user_invoices = ParticipationRequest::Invoice.all.includes(:participation_request)
    @pro_invoices  = Subscriptions::Invoice.all.includes(:structure)
  end
end
