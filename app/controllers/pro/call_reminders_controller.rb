class Pro::CallRemindersController < Pro::ProController
  before_action :authenticate_pro_super_admin!, except: [:index, :new]

  layout 'admin'

  def new
    @call_reminder = CallReminder.new
    render layout: false
  end

  def index
    @call_reminders = CallReminder.all
  end

  def create
    CallReminder.create call_reminder_params
    respond_to do |format|
      format.js
    end
  end

  def update
    @call_reminder = CallReminder.find params[:id]
    @call_reminder.update_attributes call_reminder_params
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

  private

  def call_reminder_params
    params.require(:call_reminder).permit(:name, :phone_number, :website, :comment)
  end
end
