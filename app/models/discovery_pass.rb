class DiscoveryPass < ActiveRecord::Base
  include Concerns::HstoreHelper
  acts_as_paranoid

  PRICE = 19 # €

  ######################################################################
  # Callbacks                                                          #
  ######################################################################
  after_create :change_sponsorship_state
  after_create :inform_user_of_success
  before_create :set_expires_at

  ######################################################################
  # Relations                                                          #
  ######################################################################
  belongs_to :user
  belongs_to :sponsorship

  ######################################################################
  # Scope                                                              #
  ######################################################################
  scope :not_canceled,            -> { where(canceled_at: nil) }
  scope :expires_in_five_days,    -> { where( arel_table[:expires_at].gt(Date.today + 4.days).and(
                                              arel_table[:expires_at].lteq(Date.today + 5.days)) ) }

  attr_accessible :expires_at, :renewed_at, :last_renewal_failed_at, :canceled_at, :sponsorship,
                  :credit_card_number, :be2bill_alias, :client_ip, :card_validity_date,
                  :cancelation_reason_text, :cancelation_reason_i_dont_want_to_try_more_courses, :cancelation_reason_i_found_a_course

  store_accessor :meta_data, :cancelation_reason_text, :cancelation_reason_i_dont_want_to_try_more_courses, :cancelation_reason_i_found_a_course

  define_boolean_accessor_for :meta_data, :cancelation_reason_i_dont_want_to_try_more_courses, :cancelation_reason_i_found_a_course

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

    extra_data = { renew: true }
    params_for_hash = {
      'ALIAS'           => self.be2bill_alias,
      'ALIASMODE'       => 'subscription',
      'CLIENTIDENT'     => self.user.id,
      'CLIENTEMAIL'     => self.user.email,
      'AMOUNT'          => self.next_amount_for_be2bill,
      'DESCRIPTION'     => "Renouvellement :  Pass découverte",
      'IDENTIFIER'      => ENV['BE2BILL_LOGIN'],
      'OPERATIONTYPE'   => 'payment',
      'ORDERID'         => Order::Pass.next_order_id_for(self.user),
      'VERSION'         => '2.0',
      'CLIENTUSERAGENT' => 'Mozilla/5.0 (Windows NT 6.1; WOW64)',
      'CLIENTIP'        => self.client_ip,
      'EXTRADATA'       => extra_data.merge({ product_type: 'discovery_pass'}).to_json
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
    DiscoveryPassMailer.delay.your_pass_renewed(self)
  end

  # Extend the duration of the subscription by changing its expires_at date.
  #
  # @return nil
  def extend_subscription_expires_date
    AdminMailer.delay.subscription_has_been_renewed(self)
    self.renewed_at = Date.today
    self.expires_at = Date.today + 1.month
    self.save
  end

  # Amount of the current subscription plan
  # Will return the amount with the promo applied if there is one.
  #
  # @return Integer
  def amount
    if sponsorship
      PRICE - sponsorship.credit_for_sponsored_user
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


  # The amount to pay at the next renewal, taking sponsorships into account.
  #
  # @return Integer next amount to pay
  def next_amount
    amount = PRICE
    sponsorships = self.user.sponsorships.where(state: "bought")

    sponsorships.each do |sponsorship|
      if (amount - Sponsorship::USER_WHO_SPONSORED_CREDIT) > 0
        amount -= Sponsorship::USER_WHO_HAVE_BEEN_SPONSORED_CREDIT
        sponsorship.update_state
      else
        break
      end
    end

    amount
  end

  # See next_amount
  #
  # @return Integer next amount to pay, Be2bill formatted
  def next_amount_for_be2bill
    self.next_amount * 100
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
    DiscoveryPassMailer.delay.you_deactivated_your_pass(self)
    return self
  end

  # Reactivate subscription plan by removing canceled_at
  #
  # @return SubscriptionPlan
  def reactivate!
    self.canceled_at = nil
    self.save
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
    DiscoveryPassMailer.delay.your_discovery_pass_is_active(self)
    DiscoveryPassMailer.delay.your_sponsorship_is_active(self)
  end

  # Set default expires at
  def set_expires_at
    self.expires_at ||= 1.month.from_now
  end

  # Update status of all Sponsorship attached to user that just bought the pass
  #
  # @return nil
  def change_sponsorship_state
    Sponsorship.where(sponsored_user_id: self.user.id).map(&:update_state)
    nil
  end
end
