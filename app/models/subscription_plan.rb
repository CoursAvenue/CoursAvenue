class SubscriptionPlan < ActiveRecord::Base
  acts_as_paranoid
  include Concerns::HstoreHelper

  PLAN_TYPE = %w(monthly yearly three_months six_months_half_price)

  NEXT_PLAN_TYPE = {
    'monthly'                 => 'monthly',
    'three_months'            => 'monthly',
    'six_months_half_price'   => 'monthly',
    'yearly'                  => 'yearly'
  }

  PLAN_TYPE_PRICES = {
    'monthly'               => 34, # €
    'three_months'          => 69, # €
    'six_months_half_price' => 102, # €
    'yearly'                => 348 # €
  }
  PLAN_TYPE_FREQUENCY = {
    'monthly'      => 'tous les mois',
    'three_months' => 'tous les 3 mois',
    'yearly'       => 'tous les ans'
  }
  PLAN_TYPE_DESCRIPTION = {
    'monthly'               => 'Abonnement mensuel',
    'three_months'          => 'Abonnement pour 3 mois',
    'six_months_half_price' => 'Abonnement pour 6 mois',
    'yearly'                => 'Abonnement annuel'
  }
  PLAN_TYPE_DURATION = {
    'monthly'               => 1, # month
    'three_months'          => 3, # months
    'six_months_half_price' => 6, # months
    'yearly'                => 12 # months
  }

  ######################################################################
  # Relations                                                          #
  ######################################################################
  has_many :orders
  belongs_to :structure

  attr_accessible :plan_type, :expires_at, :renewed_at, :recurrent, :structure, :canceled_at,
                  :credit_card_number, :be2bill_alias, :client_ip, :card_validity_date,
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
    subscription_plan = structure.subscription_plans.create({ plan_type: plan_type.to_s,
                                                              expires_at: Date.today + PLAN_TYPE_DURATION[plan_type.to_s].months,
                                                              credit_card_number: params[:CARDCODE],
                                                              recurrent: true,
                                                              be2bill_alias: params[:ALIAS],
                                                              card_validity_date: (params[:CARDVALIDITYDATE] ? Date.strptime(params[:CARDVALIDITYDATE], '%m-%y') : nil),
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
    require 'net/http'

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
      'CLIENTIP'        => self.client_ip
    }
    params = {}
    params['params[HASH]'] = SubscriptionPlan.hash_be2bill_params params_for_hash
    params_for_hash.each do |key, value|
      params["params[#{key}]"] = value
    end

    params['method']          = 'payment'

    # res = Net::HTTP.post_form URI('http://coursavenue.dev'), params
    res = Net::HTTP.post_form URI(ENV['BE2BILL_REST_URL']), params
    puts res.body if res.is_a?(Net::HTTPSuccess)
    return res.is_a?(Net::HTTPSuccess)
  end

  # Amount of the current subscription plan
  #
  # @return [type] [description]
  def amount
    PLAN_TYPE_PRICES[self.plan_type]
  end

  # As we can have a special offer for 6 months for instance, we don't want it to continue
  # So we this special offer has a next plan type which is the next plan that the user will subscribe to.
  # That's why we have a 'next_amount'
  #
  # @return Integer next amount to pay
  def next_amount
    PLAN_TYPE_PRICES[NEXT_PLAN_TYPE[self.plan_type]]
  end

  # See amount
  #
  # @return Integer next amount to pay, Be2bill formatted
  def amount_for_be2bill
    self.amount * 100
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

  def active?
    !canceled? and self.expires_at >= Date.today
  end

  def self.premium_type_from_be2bill_amount amount
    amount = amount.to_i
    PLAN_TYPE_PRICES.each do |plan_type, plan_type_amount|
      return plan_type if plan_type_amount * 100 == amount
    end
    return 'yearly'
  end

end
