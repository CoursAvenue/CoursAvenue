# encoding: utf-8
class Users::RegistrationsController < Devise::RegistrationsController
  respond_to :html, :js, :json

  def after_inactive_sign_up_path_for(user)
    waiting_for_activation_users_path
  end

  def after_sign_in_path_for(user)
    session['user_return_to'] || request.referrer || root_path
  end

  # Method taken from devise lib
  def create
    ## Start of changes
    if (@user = User.inactive.where(email: params[:user][:email]).first).nil?
      @user = User.new params[:user]
      build_resource(sign_up_params)
    else
      self.resource = @user
      self.resource.update_attributes params[:user]
    end
    resource.after_sign_up_url = session['user_return_to']
    ## end of changes
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

  def new
    respond_to do |format|
      format.html { render layout: !request.xhr? }
    end
  end
end
