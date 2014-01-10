# encoding: utf-8
class Users::RegistrationsController < Devise::RegistrationsController
  respond_to :html, :js, :json

  def after_inactive_sign_up_path_for(user)
    waiting_for_activation_users_path
  end

  def after_sign_in_path_for(user)
    session['user_return_to'] || request.referrer || root_path
  end

  def create
    if (@user = User.inactive.where(email: params[:user][:email]).first).nil?
      @user = User.new params[:user]
      build_resource(sign_up_params)
    else
      self.resource = @user
      self.resource.update_attributes params[:user]
    end
    if resource.save
      resource.send_confirmation_instructions
      yield resource if block_given?
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_flashing_format?
        sign_up(resource_name, resource)
        respond_with resource, :location => after_sign_up_path_for(resource)
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_flashing_format?
        expire_data_after_sign_in!
        respond_with resource, :location => after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      respond_with resource
    end
  end

  # def create
  #   # As users are created when they post a comment, or teachers invite them to post one
  #   # We update the user if it exists, else we create a new one.
  #   if (@user = User.inactive.where(email: params[:user][:email]).first).nil?
  #     @user = User.new params[:user]
  #   else
  #     @user.update_attributes params[:user]
  #   end
  #   respond_to do |format|
  #     if @user.save
  #       sign_in(@user, bypass: true)
  #       azd?
  #       format.html { redirect_to(root_path, notice: 'Vous êtes bien enregistré. Vous devez valider votre compte.') }
  #     else
  #       format.html { render action: 'new' }
  #     end
  #   end
  # end

  def new
    respond_to do |format|
      format.html { render layout: !request.xhr? }
    end
  end
end
