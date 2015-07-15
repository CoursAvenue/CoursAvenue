class Pro::SmsLoggersController < Pro::ProController
  before_action :authenticate_pro_super_admin!
  layout 'admin'

  def index
    @sms_loggers = SmsLogger.order('created_at DESC').page(params[:page] || 1).per(50)
  end
end
