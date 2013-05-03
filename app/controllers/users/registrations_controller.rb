# encoding: utf-8
class Users::RegistrationsController < Devise::RegistrationsController
  respond_to :html, :js, :json
  def create
    @user     = User.new params[:user]
    respond_to do |format|
      if @user.save
        # AdminMailer.new_user_has_signed_up(@admin).deliver
        # format.html { redirect_to root_path, notice: 'Un email de confirmation vient de vous être envoyé' }
        sign_in @user
        # UserMailer.welcome(@user).deliver
        format.html { redirect_to root_path, notice: 'Un email de confirmation vient de vous être envoyé' }
      else
        format.html { render action: 'new' }
      end
    end
  end

  def new
    respond_to do |format|
      format.html { render layout: !request.xhr? }
    end
  end
end
