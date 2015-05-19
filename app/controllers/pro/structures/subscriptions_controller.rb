class Pro::Structures::SubscriptionsController < Pro::ProController
  before_action :authenticate_pro_admin!, :set_structure
  load_and_authorize_resource :structure, find_by: :slug

  layout 'admin'

  def index
    if @structure.subscription.present?
      @subscription = @structure.subscription.decorate
      @sponsorship  = Subscriptions::Sponsorship.where(token: @subscription.sponsorship_token).first
    else
      @monthly_plans = ::Subscriptions::Plan.monthly.order('amount ASC').decorate
      @yearly_plans  = ::Subscriptions::Plan.yearly.order('amount ASC').decorate
      @sponsorship   = Subscriptions::Sponsorship.where(token: session[:sponsorship_token] ||
                                                        params[:sponsorship_token]).first
    end

    @sponsorship_token = @sponsorship.present? ? @sponsorship.token : nil
  end

  def create
    plan              = Subscriptions::Plan.find(subscription_plan_id_params[:plan_id])
    coupon_code       = subscription_plan_id_params[:coupon_code]
    sponsorship_token = subscription_plan_id_params[:sponsorship_token]

    @subscription = plan.create_subscription!(@structure, coupon_code)

    if sponsorship_token.present?
      @subscription.sponsorship_token = sponsorship_token
      @subscription.save
    end

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

  def confirm_choice
    if subscription_plan_id_params[:plan_id].present?
      @plan = Subscriptions::Plan.find(subscription_plan_id_params[:plan_id])
    else
      @plan = @structure.subscription.plan
    end
    if request.xhr?
      render layout: false
    end
  end

  def choose_plan_and_pay
    @monthly_plans = ::Subscriptions::Plan.monthly.order('amount ASC').decorate
    @yearly_plans  = ::Subscriptions::Plan.yearly.order('amount ASC').decorate
    @plan          = @structure.subscription.plan
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
    plan          = Subscriptions::Plan.find(subscription_plan_id_params[:plan_id])
    @subscription.plan = plan
    @subscription.save

    error_code_value = @subscription.charge!(stripe_token_params[:stripe_token])
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

    redirect_to pro_structure_subscriptions_path(@structure), notice: 'Votre abonnement a bién été changé'
  end

  def reactivate
    @subscription = @structure.subscription
    @subscription.reactivate!

    redirect_to pro_structure_subscriptions_path(@structure), notice: 'Vous êtes maintenant réabonné'
  end

  # PATCH :id/accept_payments
  def accept_payments
    @subscription = @structure.subscription

    token        = accept_payments_permitted_params[:stripe_bank_token]
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
    params.permit(:plan_id, :coupon_code, :sponsorship_token)
  end

  def accept_payments_permitted_params
    params.require(:subscription).permit(
      :stripe_token, :stripe_bank_token, :bank_account_number,
      :address_line1, :address_line2, :address_city, :address_state, :address_postal_code,
      :address_country, :business_type, :business_name, :business_url, :business_address_line1,
      :business_address_line2, :business_name, :business_address_line1, :business_address_line2,
      :business_address_city, :business_address_state, :business_address_postal_code,
      :owner_first_name, :owner_last_name, :owner_dob_day, :owner_dob_month, :owner_dob_year,
      :owner_address_line1, :owner_address_line2, :owner_address_city, :owner_address_state,
      :owner_address_postal_code, :owner_address_country,

      :additional_owner_0_first_name, :additional_owner_0_last_name, :additional_owner_0_dob_day,
      :additional_owner_0_dob_day, :additional_owner_0_dob_month, :additional_owner_0_dob_year,
      :additional_owner_0_address_line1, :additional_owner_0_address_line2,
      :additional_owner_0_address_city, :additional_owner_0_address_postal_code,
      :additional_owner_0_address_state, :additional_owner_0_address_country,

      :additional_owner_1_first_name, :additional_owner_1_last_name, :additional_owner_1_dob_day,
      :additional_owner_1_dob_day, :additional_owner_1_dob_month, :additional_owner_1_dob_year,
      :additional_owner_1_address_line1, :additional_owner_1_address_line2,
      :additional_owner_1_address_city, :additional_owner_1_address_postal_code,
      :additional_owner_1_address_state, :additional_owner_1_address_country,

      :additional_owner_2_first_name, :additional_owner_2_last_name, :additional_owner_2_dob_day,
      :additional_owner_2_dob_day, :additional_owner_2_dob_month, :additional_owner_2_dob_year,
      :additional_owner_2_address_line1, :additional_owner_2_address_line2,
      :additional_owner_2_address_city, :additional_owner_2_address_postal_code,
      :additional_owner_2_address_state, :additional_owner_2_address_country
    )
  end

  def build_legal_entity(form_params)
    additional_owners = build_additional_owners(accept_payments_permitted_params)
    {
      address: {
        line1:       form_params[:business_address_line1],
        line2:       form_params[:business_address_line2],
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
      business_url:  form_params[:business_url],
      first_name:    form_params[:owner_first_name],
      last_name:     form_params[:owner_last_name],
      type:          form_params[:business_type],
      additional_owners: additional_owners
    }
  end

  def build_additional_owners(form_params)
    # We test the opposite of the presence because it tests both if the variable is nil and empty.
    return nil if ! form_params[:additional_owner_0_first_name].present? and
      ! form_params[:additional_owner_1_first_name].present? and
      ! form_params[:additional_owner_2_first_name].present?

    owner_0 = {
      first_name: form_params[:additional_owner_0_first_name],
      last_name:  form_params[:additional_owner_0_last_name],
      dob: {
        day:   form_params[:additional_owner_0_dob_day],
        month: form_params[:additional_owner_0_dob_month],
        year:  form_params[:additional_owner_0_dob_year],
      },
      address: {
        line1:       form_params[:additional_owner_0_address_line1],
        line2:       form_params[:additional_owner_0_address_line2],
        city:        form_params[:additional_owner_0_address_city],
        state:       form_params[:additional_owner_0_address_state],
        postal_code: form_params[:additional_owner_0_address_postal_code],
        country:     'FR',
      },
    }

    owner_1 = {
      first_name: form_params[:additional_owner_1_first_name],
      last_name:  form_params[:additional_owner_1_last_name],
      dob: {
        day:   form_params[:additional_owner_1_dob_day],
        month: form_params[:additional_owner_1_dob_month],
        year:  form_params[:additional_owner_1_dob_year],
      },
      address: {
        line1:       form_params[:additional_owner_1_address_line1],
        line2:       form_params[:additional_owner_1_address_line2],
        city:        form_params[:additional_owner_1_address_city],
        state:       form_params[:additional_owner_1_address_state],
        postal_code: form_params[:additional_owner_1_address_postal_code],
        country:     'FR',
      },
    }

    owner_2 = {
      first_name: form_params[:additional_owner_2_first_name],
      last_name:  form_params[:additional_owner_2_last_name],
      dob: {
        day:   form_params[:additional_owner_2_dob_day],
        month: form_params[:additional_owner_2_dob_month],
        year:  form_params[:additional_owner_2_dob_year],
      },
      address: {
        line1:       form_params[:additional_owner_2_address_line1],
        line2:       form_params[:additional_owner_2_address_line2],
        city:        form_params[:additional_owner_2_address_city],
        state:       form_params[:additional_owner_2_address_state],
        postal_code: form_params[:additional_owner_2_address_postal_code],
        country:     'FR',
      },
    }

    [owner_0, owner_1, owner_2]
  end
end
