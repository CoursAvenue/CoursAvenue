class Pro::CallRemindersController < Pro::ProController
  before_action :authenticate_pro_super_admin!

  layout 'admin'

  def new
    @call_reminder = CallReminder.new
    render layout: false
  end

  def index
    @call_reminders = CallReminder.all
  end

  def create
    CallReminder.create params[:call_reminder]
    respond_to do |format|
      format.js
    end
  end

  def update
    @call_reminder = CallReminder.find params[:id]
    @call_reminder.update_attributes params[:call_reminder]
    respond_to do |format|
      format.html { redirect_to pro_call_reminders_path }
    end
  end

  def destroy
    @call_reminder = CallReminder.find params[:id]
    @call_reminder.destroy
    respond_to do |format|
      format.html { redirect_to pro_call_reminders_path }
    end
  end
end
