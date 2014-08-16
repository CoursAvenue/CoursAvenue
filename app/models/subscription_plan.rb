class SubscriptionPlan < ActiveRecord::Base
  acts_as_paranoid
  include Concerns::HstoreHelper

  PLAN_TYPE = %w(monthly yearly three_months)

  NEXT_PLAN_TYPE = {
    'monthly'      => 'monthly',
    'three_months' => 'monthly',
    'yearly'       => 'yearly'
  }

  PLAN_TYPE_PRICES = {
    'monthly'      => 44, # €
    'three_months' => 69, # €
    'yearly'       => 468 # €
  }
  PLAN_TYPE_FREQUENCY = {
    'monthly'      => 'tous les mois',
    'three_months' => 'tous les 3 mois',
    'yearly'       => 'tous les ans'
  }
  PLAN_TYPE_DESCRIPTION = {
    'monthly'      => 'Abonnement mensuel',
    'three_months' => 'Abonnement pour 3 mois',
    'yearly'       => 'Abonnement annuel'
  }
  PLAN_TYPE_DURATION = {
    'monthly'      => 1, # month
    'three_months' => 3, # months
    'yearly'       => 12 # months
  }

  ######################################################################
  # Scopes                                                             #
  ######################################################################
  scope :yearly,                  -> { where( plan_type: 'yearly') }
  scope :not_monthly,             -> { where.not( plan_type: 'monthly') }
  scope :monthly,                 -> { where( plan_type: 'monthly') }
  scope :expires_in_fifteen_days, -> { where( arel_table[:expires_at].gteq(Date.today - 15.days).and(
                                              arel_table[:expires_at].lt(Date.today - 14.days)) ) }

  scope :expires_in_five_days,    -> { where( arel_table[:expires_at].gteq(Date.today - 5.days).and(
                                              arel_table[:expires_at].lt(Date.today - 4.days)) ) }
  ######################################################################
  # Callbacks                                                          #
  ######################################################################
  after_create :inform_admin_of_success
  after_initialize :check_plan_type

  ######################################################################
  # Relations                                                          #
  ######################################################################
  has_many :orders
  belongs_to :structure
  belongs_to :promotion_code

  attr_accessible :plan_type, :expires_at, :renewed_at, :last_renewal_failed_at, :recurrent, :structure, :canceled_at,
                  :credit_card_number, :be2bill_alias, :client_ip, :card_validity_date, :promotion_code_id,
                  :cancelation_reason_dont_want_more_students, :cancelation_reason_stopping_activity,
                  :cancelation_reason_didnt_have_return_on_investment, :cancelation_reason_too_hard_to_use,
                  :cancelation_reason_not_satisfied_of_coursavenue_users, :cancelation_reason_other, :cancelation_reason_text

  store_accessor :meta_data, :cancelation_reason_dont_want_more_students, :cancelation_reason_stopping_activity,
                             :cancelation_reason_didnt_have_return_on_investment, :cancelation_reason_too_hard_to_use,
                             :cancelation_reason_not_satisfied_of_coursavenue_users, :cancelation_reason_other,
                             :cancelation_reason_text

  define_boolean_accessor_for :meta_data, :cancelation_reason_dont_want_more_students, :cancelation_reason_stopping_activity,
                             :cancelation_reason_didnt_have_return_on_investment, :cancelation_reason_too_hard_to_use,
                             :cancelation_reason_not_satisfied_of_coursavenue_users, :cancelation_reason_other

  # Create a plan associated to the given structure with a monthly subscription plan
  #
  # @return SubscriptionPlan
  def self.subscribe! plan_type, structure, params={}
    if params[:EXTRADATA].present?
      promotion_code_id = params[:EXTRADATA]['promotion_code_id']
    else
      promotion_code_id = nil
    end
    subscription_plan = structure.subscription_plans.create({ plan_type: plan_type.to_s,
                                                              expires_at: Date.today + PLAN_TYPE_DURATION[plan_type.to_s].months,
                                                              credit_card_number: params[:CARDCODE],
                                                              recurrent: true,
                                                              be2bill_alias: params[:ALIAS],
                                                              card_validity_date: (params[:CARDVALIDITYDATE] ? Date.strptime(params[:CARDVALIDITYDATE], '%m-%y') : nil),
                                                              promotion_code_id: promotion_code_id,
                                                              client_ip: params[:CLIENT_IP]})
    structure.compute_search_score(true)
    structure.index
    return subscription_plan
  end

  def self.hash_be2bill_params params
    require 'digest'
    secret = ENV['BE2BILL_PASSWORD']
    string = secret.dup
    params.keys.sort.each do |key|
      next if key == 'HASH'
      string << "#{key}=#{params[key]}#{secret}"
    end
    sha256 = Digest::SHA256.new
    sha256.update string
    sha256.hexdigest
  end

  # Renew subscription by calling Be2bill API.
  #
  # @return Boolean
  def renew!
    return if self.canceled?
    require 'net/http'

    extra_data = { renew: true, plan_type: self.plan_type }
    # Passes promotion code only if the promotion code still applies on the renew
    if self.promotion_code and self.promotion_code.still_apply?
      extra_data[:promotion_code_id] = self.promotion_code_id
    else
      extra_data[:promotion_code_id] = nil
    end
    params_for_hash = {
      'ALIAS'           => self.be2bill_alias,
      'ALIASMODE'       => 'subscription',
      'CLIENTIDENT'     => self.structure.id,
      'CLIENTEMAIL'     => self.structure.main_contact.email,
      'AMOUNT'          => self.next_amount_for_be2bill,
      'DESCRIPTION'     => "Renouvellement :  #{NEXT_PLAN_TYPE[self.plan_type]}",
      'IDENTIFIER'      => ENV['BE2BILL_LOGIN'],
      'OPERATIONTYPE'   => 'payment',
      'ORDERID'         => Order.next_order_id_for(self.structure),
      'VERSION'         => '2.0',
      'CLIENTUSERAGENT' => 'Mozilla/5.0 (Windows NT 6.1; WOW64)',
      'CLIENTIP'        => self.client_ip,
      'EXTRADATA'       => extra_data.to_json
    }
    params = {}
    params['params[HASH]'] = SubscriptionPlan.hash_be2bill_params params_for_hash
    params_for_hash.each do |key, value|
      params["params[#{key}]"] = value
    end

    params['method']          = 'payment'

    res = Net::HTTP.post_form URI(ENV['BE2BILL_REST_URL']), params
    puts res.body # For debugging purpose
    if res.is_a?(Net::HTTPSuccess)
      return true
    else
      params['res_body'] = res.body
      Bugsnag.notify(RuntimeError.new("Renewal failed on HTTP call"), params)
      AdminMailer.delay.go_premium_fail(self.structure, params)
      return false
    end
  end

  # Executed by Be2bill notification callback if the renwal has been successful
  #
  # @return Boolean, saved or not
  def extend_subscription(params)
    AdminMailer.delay.subscription_has_been_renewed(self)
    #
    self.credit_card_number = params['CARDCODE']
    # Update be2bill_alias if the renew is done by the user because his card hasexpired
    self.be2bill_alias      = params['ALIAS'] if params['ALIAS'].present?
    self.card_validity_date = (params['CARDVALIDITYDATE'] ? Date.strptime(params['CARDVALIDITYDATE'], '%m-%y') : nil)
    self.renewed_at         = Date.today
    self.expires_at         = Date.today + PLAN_TYPE_DURATION[plan_type.to_s].months
    self.reactivate!
  end

  # Description of the plan
  #
  # @return Integer
  def description
    PLAN_TYPE_DESCRIPTION[self.plan_type]
  end

  # Description of the next plan
  #
  # @return Integer
  def next_plan_type_description
    PLAN_TYPE_DESCRIPTION[NEXT_PLAN_TYPE[self.plan_type]]
  end

  # Duration of the plan in months
  #
  # @return Integer
  def duration
    PLAN_TYPE_DURATION[self.plan_type]
  end

  # Amount of the current subscription plan
  #
  # @return Integer
  def amount
    PLAN_TYPE_PRICES[self.plan_type]
  end

  # See amount
  #
  # @return Integer next amount to pay, Be2bill formatted
  def amount_for_be2bill
    self.amount * 100
  end

  # Amount of the current subscription plan montly
  #
  # @return Integer
  def monthly_amount
    PLAN_TYPE_PRICES[self.plan_type] / PLAN_TYPE_DURATION[self.plan_type]
  end

  # As we can have a special offer for 6 months for instance, we don't want it to continue
  # So we this special offer has a next plan type which is the next plan that the user will subscribe to.
  # That's why we have a 'next_amount'
  #
  # @return Integer next amount to pay
  def next_amount
    if self.promotion_code and self.promotion_code.still_apply?
      PLAN_TYPE_PRICES[NEXT_PLAN_TYPE[self.plan_type]] - self.promotion_code.promo_amount
    else
      PLAN_TYPE_PRICES[NEXT_PLAN_TYPE[self.plan_type]]
    end
  end

  # See next_amount
  #
  # @return Integer next amount to pay, Be2bill formatted
  def next_amount_for_be2bill
    self.next_amount * 100
  end

  def frequency
    PLAN_TYPE_FREQUENCY[NEXT_PLAN_TYPE[self.plan_type]]
  end

  def canceled?
    self.canceled_at.present?
  end

  # Cancel subscription plan
  #
  # @return SubscriptionPlan
  def cancel!
    self.canceled_at = Time.now
    self.save
    self.structure.index
    AdminMailer.delay.subscription_has_been_canceled(self)
    return self
  end

  # Reactivate subscription plan by removing canceled_at
  #
  # @return SubscriptionPlan
  def reactivate!
    self.canceled_at = nil
    self.save
    self.structure.index
    return self
  end

  def active?
    self.expires_at >= Date.today
  end

  private

  def inform_admin_of_success
    AdminMailer.delay.your_premium_account_has_been_activated(self)
  end

  # Set plan_type to yearly if not defined
  def check_plan_type
    self.plan_type = 'yearly' unless PLAN_TYPE.include? plan_type
  end
end
