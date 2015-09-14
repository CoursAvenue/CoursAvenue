class Admin::SmsLoggersController < Admin::AdminController
  def index
    @sms_loggers = SmsLogger.order('created_at DESC').page(params[:page] || 1).per(50)
  end

  def show
    @sms = SmsLogger.find(params[:id])
    @status = @sms.status
  end
end
