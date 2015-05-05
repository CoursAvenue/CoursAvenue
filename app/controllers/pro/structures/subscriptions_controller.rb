class Pro::Structures::SubscriptionsController < Pro::ProController
  before_action :authenticate_pro_admin!, :set_structure

  layout 'admin'

  def index
    if @structure.subscription.present?
      @subscription = @structure.subscription.decorate
    else
      @monthly_plans = ::Subscriptions::Plan.monthly.order('amount ASC').decorate
      @yearly_plans  = ::Subscriptions::Plan.yearly.order('amount ASC').decorate
    end
  end

  def create
    plan        = Subscriptions::Plan.find(subscription_plan_id_params[:plan_id])
    coupon_code = params[:coupon_code]

    @subscription = plan.create_subscription!(@structure, coupon_code)

    respond_to do |format|
      if @subscription.present? and @subscription.persisted?
        format.html { redirect_to pro_structure_subscriptions_path(@structure),
                      notice: 'Votre abonnement a été créé avec succés' }
      else
        format.html { redirect_to pro_structure_subscriptions_path(@structure),
                      error: "Erreur lors de la création de l'abonnement, veuillez rééssayer.",
                      status: 400 }
      end
    end
  end

  def cancel
    @subscription = @structure.subscription

    if request.xhr?
      render layout: false
    end
  end

  def confirm_cancellation
    @subscription = @structure.subscription

    if request.xhr?
      render layout: false
    end
  end

  def stripe_payment_form
    @subscription = @structure.subscription.decorate

    if request.xhr?
      render layout: false
    end
  end

  def destroy
    @subscription = @structure.subscription

    @subscription.update_attributes(params[:subscription])
    @subscription.cancel!

    redirect_to pro_structure_subscriptions_path(@structure), notice: 'Vous êtes maintenant désabonné'
  end

  def activate
    @subscription = @structure.subscription

    error_code_value = @subscription.charge! stripe_token_params[:stripe_token]
    respond_to do |format|
      if error_code_value.nil?
        format.html { redirect_to pro_structure_subscriptions_path(@structure), notice: 'Vous êtes maintenant abonné !' }
      else
        format.html { redirect_to pro_structure_subscriptions_path(@structure), notice: 'Vous êtes maintenant abonné !' }
      end
    end
  end

  def choose_new_plan
    @subscription  = @structure.subscription
    @monthly_plans = ::Subscriptions::Plan.monthly.order('amount ASC').decorate
    @yearly_plans  = ::Subscriptions::Plan.yearly.order('amount ASC').decorate

    if request.xhr?
      render layout: false
    end
  end

  def change_plan
    @subscription = @structure.subscription
    plan          = Subscriptions::Plan.find(subscription_plan_id_params[:plan_id])
    @subscription.change_plan!(plan)

    redirect_to pro_structure_subscriptions_path(@structure), notice: 'Vous êtes maintenant réabonné'
  end

  def reactivate
    @subscription = @structure.subscription
    @subscription.reactivate!

    redirect_to pro_structure_subscriptions_path(@structure), notice: 'Vous êtes maintenant réabonné'
  end

  # PATCH :id/accept_payments
  # TODO: additional_owners (show more on demand)
  def accept_payments
    @subscription = @structure.subscription

    token = accept_payments_permitted_params[:stripe_bank_token]
    legal_entity = build_legal_entity(accept_payments_permitted_params)

    managed_account_options = {
      legal_entity:   legal_entity,
      bank_account:   token,
      tos_acceptance: {
        date: Time.now.to_i,
        ip: request.ip
      }
    }

    created = @structure.create_managed_account(managed_account_options)

    if created
      redirect_to pro_structure_subscriptions_path(@structure),
        notice: 'Vos informations ont été reçus avec succès'
    else
      redirect_to pro_structure_subscriptions_path(@structure),
        error: 'Une erreur est survenue, veuillez rééssayer.'
    end
  end

  private

  def set_structure
    @structure = Structure.find(params[:structure_id])
  end

  def stripe_token_params
    params.require(:subscription).permit(:stripe_token)
  end

  def subscription_plan_id_params
    params.permit(:plan_id)
  end

  def accept_payments_permitted_params
    params.require(:subscription).permit(
      :stripe_token, :stripe_bank_token, :bank_account_number,
      :address_line1, :address_line2, :address_city, :address_state, :address_postal_code,
      :address_country, :business_type, :business_name, :business_address_line1,
      :business_address_line2, :business_name, :business_address_line1, :business_address_line2,
      :business_address_city, :business_address_state, :business_address_postal_code,
      :owner_first_name, :owner_last_name, :owner_dob_day, :owner_dob_month, :owner_dob_year,
      :owner_address_line1, :owner_address_line2, :owner_address_city, :owner_address_state,
      :owner_address_postal_code, :owner_address_country)
  end

  def build_legal_entity(form_params)
    {
      address: {
        line1:       form_params[:business_address_line1],
        line2:       form_params[:business_address_line1],
        city:        form_params[:business_address_city],
        state:       form_params[:business_address_state],
        postal_code: form_params[:business_address_postal_code],
        country:     'FR',
      },
      dob: {
        day:   form_params[:owner_dob_day],
        month: form_params[:owner_dob_month],
        year:  form_params[:owner_dob_year],
      },
      personal_address: {
        line1:       form_params[:owner_address_line1],
        city:        form_params[:owner_address_city],
        state:       form_params[:owner_address_state],
        postal_code: form_params[:owner_address_postal_code],
        country:     'FR',
      },
      business_name: form_params[:business_name],
      first_name: form_params[:owner_first_name],
      last_name: form_params[:owner_last_name],
      type: form_params[:business_type],
      additional_owners: nil,
    }
  end
end
