class Users::InvitedUsersController < ApplicationController
  before_action :authenticate_user!, except: [:bulk_create_jpo]
  load_and_authorize_resource :user, except: [:bulk_create_jpo]

  layout 'user_profile'

  def index
    @invited_users = current_user.invited_users
  end

  def jpo
    @invited_users = current_user.invited_users.for_jpo
  end

  def jpo_new
    @user      = current_user
    if @user.participations.not_canceled.any?
      @structure     = @user.participations.last.structure
      @participation = @user.participations.not_canceled.last
    else
      @structure = Structure.find(params[:structure_id]) if params[:structure_id].present?
    end
  end

  def new
  end

  def bulk_create_jpo
    params[:emails] ||= ''
    regexp = Regexp.new(/\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}\b/)
    emails = params[:emails].scan(regexp).uniq
    text   = '<p>' + params[:text].gsub(/\r\n/, '</p><p>') + '</p>' if params[:text].present?

    if current_user.nil?
      @user            = User.where(email: params[:user][:email]).first
      @user.first_name = params[:user][:name]
      @user.save(validate: false)
    else
      @user = current_user
    end

    emails.each do |_email|
      invited_user = InvitedUser::Student.where(for: 'jpo', email: _email, referrer_id: @user.id, referrer_type: 'User', email_text: text).first_or_create
      if params[:structure] and params[:structure][:id].present?
        invited_user.structure_id = params[:structure][:id]
        invited_user.save
      end
      InvitedUserMailer.delay.recommand_friends(invited_user)
    end

    respond_to do |format|
      if @user.active?
        format.html { redirect_to jpo_user_invited_users_path(@user), notice: (params[:emails].present? ? 'Vos amis ont bien été notifiés.' : nil) }
      else
        format.html { redirect_to new_user_registration_path, notice: (params[:emails].present? ? 'Vos amis ont bien été notifiés.' : nil) }
      end
    end
  end

  def bulk_create
    params[:emails] ||= ''
    regexp = Regexp.new(/\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}\b/)
    emails = params[:emails].scan(regexp).uniq
    text = '<p>' + params[:text].gsub(/\r\n/, '</p><p>') + '</p>' if params[:text].present?

    emails.each do |_email|
      invited_user = InvitedUser::Student.where(for: nil, email: _email, referrer_id: current_user.id, referrer_type: 'User', email_text: text).first_or_create
      InvitedUserMailer.delay.recommand_friends(invited_user)
    end

    respond_to do |format|
      format.html { redirect_to user_invited_users_path(current_user), notice: (params[:emails].present? ? 'Vos amis ont bien été notifiés.' : nil) }
    end
  end
end
