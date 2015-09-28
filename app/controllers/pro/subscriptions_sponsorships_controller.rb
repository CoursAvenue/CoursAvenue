class Pro::SubscriptionsSponsorshipsController < Pro::PublicController
  layout 'home'

  def show
    @token = params[:id]

    @sponsorship = Subscriptions::Sponsorship.where(token: @token).first
    if @sponsorship.nil?
      return redirect_to pro_root_path, error: 'Parrainage introuvable.'
    end

    session[:sponsorship_token] = @token
    if current_pro_admin and current_pro_admin.structure
      return redirect_to pro_structure_subscriptions_path(current_pro_admin.structure,
                                                          sponsorship_token: @token)
    end

    # The placeholder is updated in the method `pro/admin/session#after_sign_in_path_for`.
    session[:pro_admin_return_to] = pro_structure_subscriptions_path('__STRUCTURE_ID__',
                                                                     sponsorship_token: @token)

    @structure = @sponsorship.subscription.structure
  end
end
