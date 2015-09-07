# encoding: utf-8
class Users::RegistrationsController < Devise::RegistrationsController
  respond_to :html, :json

  layout :choose_layout

  def after_inactive_sign_up_path_for(user)
    session['after_inactive_sign_up_path'] || waiting_for_activation_users_path(email: user.email)
  end

  # Method taken from devise lib
  def create
    if params[:user] and params[:user][:name]
      params[:user][:first_name] = params[:user][:name].split(' ')[0..params[:user][:name].split(' ').length - 2].join(' ')
      params[:user][:last_name]  = params[:user][:name].split(' ').last if self.params[:user][:name].split(' ').length > 1
      params[:user].delete :name
    end

    ## Start of changes
    if (@user = User.inactive.where(email: params[:user][:email]).first).nil?
      @user = User.new params[:user]
      build_resource(sign_up_params)
    else
      self.resource = @user
      @user.update_column :sign_up_at, Time.now
      resource.update_attributes params[:user]
    end
    resource.after_sign_up_url = session['user_return_to'] || params[:user_return_to]
    ## end of changes
    if resource.save
      # resource.send_confirmation_instructions
      resource.after_registration
      yield resource if block_given?
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_flashing_format?
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_flashing_format?
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      respond_with resource
    end
  end

  def new
    session['user_return_to'] = request.referrer
    @is_xhr = request.xhr?
    respond_to do |format|
      if request.xhr?
        format.html { render partial: 'popup_new', layout: false }
      else
        format.html { render }
      end
    end
  end

  private

  def choose_layout
    if action_name == 'edit'
      'user_profile'
    else
      'users'
    end
  end
end
