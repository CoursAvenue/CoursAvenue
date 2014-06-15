class SubscriptionPlan < ActiveRecord::Base
  acts_as_paranoid
  include Concerns::HstoreHelper

  PLAN_TYPE = %w(monthly yearly three_months)
  PLAN_TYPE_PRICES = {
    'monthly'      => 34, # €
    'three_months' => 69, # €
    'yearly'       => 348 # €
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
  # Relations                                                          #
  ######################################################################
  has_many :orders
  belongs_to :structure

  attr_accessible :plan_type, :expires_at, :renewed_at, :recurrent, :structure, :canceled_at,
                  :credit_card_number, :be2bill_alias,
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
  # @return Boolean
  def self.subscribe! plan_type, structure, params={}
    SubscriptionPlan.create structure: structure,
                            plan_type: plan_type.to_s,
                            expires_at: Date.today + PLAN_TYPE_DURATION[plan_type.to_s].month,
                            credit_card_number: params[:CARDCODE],
                            recurrent: true,
                            be2bill_alias: params[:ALIAS],
                            client_ip: params[:CLIENT_IP]
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

  def renew!
    require 'net/http'

    params_for_hash = {
      'ALIAS'           => self.be2bill_alias,
      'ALIASMODE'       => 'subscription',
      'CLIENTIDENT'     => self.structure.id,
      'CLIENTEMAIL'     => self.structure.main_contact.email,
      'AMOUNT'          => self.amount_for_be2bill,
      'DESCRIPTION'     => "Renouvellement :  LAN_TYPE_DESCRIPTION[self.plan_type]}",
      'IDENTIFIER'      => ENV['BE2BILL_LOGIN'],
      'OPERATIONTYPE'   => 'payment',
      'ORDERID'         => Order.next_order_id_for(self.structure),
      'VERSION'         => '2.0',
      'CLIENTUSERAGENT' => 'Mozilla/5.0 (Windows NT 6.1; WOW64)',
      'CLIENTIP'        => '120.12.41.24',
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
  end

  def amount
    PLAN_TYPE_PRICES[self.plan_type]
  end

  def amount_for_be2bill
    PLAN_TYPE_PRICES[self.plan_type] * 100
  end

  def frequency
    PLAN_TYPE_FREQUENCY[self.plan_type]
  end

  def canceled?
    self.canceled_at.present?
  end

  def active?
    !canceled? and self.expires_at >= Date.today
  end
end
