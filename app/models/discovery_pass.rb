class DiscoveryPass < ActiveRecord::Base
  acts_as_paranoid

  PRICE = 19 # €

  ######################################################################
  # Callbacks                                                          #
  ######################################################################
  after_create :inform_user_of_success

  ######################################################################
  # Relations                                                          #
  ######################################################################
  belongs_to :user
  belongs_to :promotion_code

  attr_accessible :expires_at, :renewed_at, :last_renewal_failed_at, :recurrent, :canceled_at,
                  :credit_card_number, :be2bill_alias, :client_ip, :card_validity_date, :promotion_code_id

  #
  # Generates a unique Order ID for a given user
  # @param user [type] [description]
  #
  # @return String: Unique string
  def self.next_order_id_for_user user
    order_number = user.discovery_passes.count + 1
    "FR#{Date.today.year}#{user.id}#{order_number}"
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


  # @return Boolean
  def renew!
    return if self.canceled?
    return renew_with_be2bill!
    return true
  end

  #
  # Renew subscription by calling Be2bill API.
  #
  # @return Boolean, wether if succeeded or failed
  def renew_with_be2bill!
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
      'DESCRIPTION'     => "Renouvellement :  #{self.plan_type}",
      'IDENTIFIER'      => ENV['BE2BILL_LOGIN'],
      'OPERATIONTYPE'   => 'payment',
      'ORDERID'         => Order.next_order_id_for(self.structure),
      'VERSION'         => '2.0',
      'CLIENTUSERAGENT' => 'Mozilla/5.0 (Windows NT 6.1; WOW64)',
      'CLIENTIP'        => self.client_ip,
      'EXTRADATA'       => extra_data.to_json
    }
    params = {}
    params['params[HASH]'] = DiscoveryPass.hash_be2bill_params params_for_hash
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

  # Extend the current subscription
  # Executed by Be2bill notification callback if the renwal has been successful
  #
  # @return Boolean, saved or not
  def extend_be2bill_subscription(params)
    self.credit_card_number = params['CARDCODE'] if params['ALIAS'].present?
    # Update be2bill_alias if the renew is done by the user because his card hasexpired
    self.be2bill_alias      = params['ALIAS'] if params['ALIAS'].present?
    self.card_validity_date = (params['CARDVALIDITYDATE'] ? Date.strptime(params['CARDVALIDITYDATE'], '%m-%y') : nil)
    self.extend_subscription_expires_date
  end

  # Extend the duration of the subscription by changing its expires_at date.
  #
  # @return nil
  def extend_subscription_expires_date
    AdminMailer.delay.subscription_has_been_renewed(self)
    self.renewed_at = Date.today
    self.expires_at = Date.today + PLAN_TYPE_DURATION[plan_type.to_s].months
    self.save
  end

  # Amount of the current subscription plan
  # Will return the amount with the promo applied if there is one.
  #
  # @return Integer
  def amount
    if self.promotion_code and self.promotion_code.still_apply? and self.plan_type == self.promotion_code.plan_type
      PRICE - self.promotion_code.promo_amount
    else
      PRICE
    end
  end

  # See amount
  #
  # @return Integer next amount to pay, Be2bill formatted
  def amount_for_be2bill
    self.amount * 100
  end

  # As we can have a special offer for 6 months for instance, we don't want it to continue
  # So we this special offer has a next plan type which is the next plan that the user will subscribe to.
  # That's why we have a 'next_amount'
  #
  # @return Integer next amount to pay
  def next_amount
    if self.promotion_code and self.promotion_code.still_apply?
      PRICE - self.promotion_code.promo_amount
    else
      PRICE
    end
  end

  # See next_amount
  #
  # @return Integer next amount to pay, Be2bill formatted
  def next_amount_for_be2bill
    self.next_amount * 100
  end

  def frequency
    PLAN_TYPE_FREQUENCY[self.plan_type]
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
    SuperAdminMailer.delay.someone_canceled_his_subscription(self)
    return self
  end

  # Reactivate subscription plan by removing canceled_at
  #
  # @return SubscriptionPlan
  def reactivate!
    self.canceled_at = nil
    self.save
    AdminMailer.delay.subscription_has_been_reactivated(self)
    SuperAdminMailer.delay.someone_reactivated_his_subscription(self)
    return self
  end

  # Tells wether the pass is still valid
  #
  # @return Boolean
  def active?
    self.expires_at >= Date.today
  end

  private

  def inform_user_of_success
    # AdminMailer.delay.your_premium_account_has_been_activated(self)
  end

end
