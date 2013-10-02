# encoding: utf-8
class Users::RegistrationsController < Devise::RegistrationsController
  respond_to :html, :js, :json

  def create
    @user     = User.new params[:user]
    respond_to do |format|
      if @user.save
        sign_in @user
        UserMailer.welcome(@user).deliver!
        format.html { redirect_to request.referrer || root_path, notice: 'Vous êtes bien enregistré. Vous êtes maintenant connecté.' }
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
