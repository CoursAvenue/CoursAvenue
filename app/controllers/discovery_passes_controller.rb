# encoding: utf-8
class DiscoveryPassesController < Pro::ProController

  layout 'discovery_pass'

  def index
    if current_user
      redirect_to user_discovery_passes_path(current_user)
    end
    if cookies[:discovery_pass_danse_test]
      redirect_to get_danse_discovery_passes_path
    end
  end

  def get_danse
    if current_user
      redirect_to user_discovery_passes_path(current_user)
    end
  end

  def test_a
    if current_user
      redirect_to user_discovery_passes_path(current_user)
    end
  end

  def test_b
    if current_user
      redirect_to user_discovery_passes_path(current_user)
    end
  end

  def create
    if params[:user][:email].blank? or !params[:user][:email].include?('@')
      if params[:waiting_list].present?
        redirect_to request.referrer, alert: 'Vous devez renseigner un e-mail valide'
      elsif cookies[:discovery_pass_danse_test]
        redirect_to get_danse_discovery_passes_path(email: params[:user][:email], promo_code: params[:promo_code], error: 'email')
      else
        redirect_to discovery_passes_path(email: params[:user][:email], promo_code: params[:promo_code], error: 'email')
      end
    else
      user = User.create_or_find_from_email(params[:user][:email])
      user.interested_in_discovery_pass = true
      user.test_name                    = params[:user][:test_name]
      user.save(validate: false)
      if params[:waiting_list].present?
        redirect_to request.referrer, notice: "Félicitations ! Nous venons de vous inscrire sur notre liste d'attente. Dès que le Pass devient disponible, nous vous préviendrons pas e-mail."
      else
        redirect_to create_account_discovery_passes_path(email: params[:user][:email], promo_code: params[:promo_code])
      end
    end
  end

  def create_account
    if current_user
      redirect_to new_user_discovery_pass_path(current_user)
    end
    # This will redirect on the right path: new discovery pass path
    session['user_return_to'] = create_account_discovery_passes_path
    @user = User.where(email: params[:email]).first || User.new
  end

  protected

  def layout_locals
    locals = { hide_menu: true }
    locals[:top_menu_header_class] = 'hidden'
    locals[:hide_top_menu_search] = true
    locals
  end
end
