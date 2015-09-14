class Users::InvitedUsersController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource :user

  layout 'user_profile'

  def index
    @invited_users = @user.invited_users
  end

  def new
  end

  def bulk_create
    params[:emails] ||= ''
    regexp = Regexp.new(/\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}\b/)
    emails = params[:emails].scan(regexp).uniq
    text = '<div class="p">' + params[:text].gsub(/\r\n\r\n/, '</div><div class="p">').gsub(/\r\n/, '<br>') + '</div>' if params[:text].present?

    emails.each do |_email|
      invited_user = InvitedUser::Student.where(invitation_for: nil, email: _email, referrer_id: @user.id, referrer_type: 'User', email_text: text).first_or_create
      InvitedUserMailer.delay(queue: 'mailers').recommand_friends(invited_user)
    end

    respond_to do |format|
      format.html { redirect_to user_invited_users_path(@user), notice: (params[:emails].present? ? 'Vos amis ont bien été notifiés.' : nil) }
    end
  end
end
