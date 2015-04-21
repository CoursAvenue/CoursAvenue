class Users::InvitedUsersController < ApplicationController
  before_action :authenticate_user!, except: [:bulk_create_jpo]
  load_and_authorize_resource :user, except: [:bulk_create_jpo]

  layout 'user_profile'

  def index
    @invited_users = @user.invited_users
  end

  def jpo
    @invited_users = @user.invited_users.for_jpo
  end

  def jpo_new
    @user      = @user
    if params[:participation_id].present?
      @participation = @user.participations.find(params[:participation_id])
      @structure     = @participation.structure
    elsif params[:structure_id].present?
      @structure = Structure.friendly.find(params[:structure_id])
    elsif @user.participations.length == 1
      @participation = @user.participations.first
      @structure     = @participation.structure
    end
  end

  def new
  end

  def bulk_create_jpo
    params[:emails] ||= ''
    regexp = Regexp.new(/\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}\b/)
    emails = params[:emails].scan(regexp).uniq
    text   = '<div class="p">' + params[:text].gsub(/\r\n\r\n/, '</div><div class="p">').gsub(/\r\n/, '<br>') + '</div>' if params[:text].present?

    if params[:user_id]
      @user = User.find params[:user_id]
    elsif @user.nil?
      @user            = User.where(email: params[:user][:email]).first
      @user.first_name = params[:user][:name]
      @user.save(validate: false)
    end

    emails.each do |_email|
      invited_user = InvitedUser::Student.where(invitation_for: 'jpo', email: _email, referrer_id: @user.id, referrer_type: 'User', email_text: text).first_or_create
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
    text = '<div class="p">' + params[:text].gsub(/\r\n\r\n/, '</div><div class="p">').gsub(/\r\n/, '<br>') + '</div>' if params[:text].present?

    emails.each do |_email|
      invited_user = InvitedUser::Student.where(invitation_for: nil, email: _email, referrer_id: @user.id, referrer_type: 'User', email_text: text).first_or_create
      InvitedUserMailer.delay.recommand_friends(invited_user)
    end

    respond_to do |format|
      format.html { redirect_to user_invited_users_path(@user), notice: (params[:emails].present? ? 'Vos amis ont bien été notifiés.' : nil) }
    end
  end
end
