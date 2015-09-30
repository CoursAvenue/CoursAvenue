class Admin::SubscriptionsInvoicesController < Admin::AdminController

  def index
    @user_invoices = ParticipationRequest::Invoice.all.includes(:participation_request)
    @pro_invoices  = Subscriptions::Invoice.all.includes(:structure)
  end
end
