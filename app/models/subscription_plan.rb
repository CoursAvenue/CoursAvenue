class SubscriptionPlan < ActiveRecord::Base
  acts_as_paranoid
  include Concerns::HstoreHelper

  PLAN_TYPE = %w(monthly yearly three_months)
  PLAN_TYPE_PRICES = {
    'monthly'      => 34, # €
    'three_months' => 68, # €
    'yearly'       => 348 # €
  }
  PLAN_TYPE_FREQUENCY = {
    'monthly'      => 'tous les mois',
    'three_months' => 'tous les 3 mois',
    'yearly'       => 'tous les ans'
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

  attr_accessible :plan_type, :expires_at, :renewed_at, :credit_card_number, :recurrent, :structure, :canceled_at,
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
                            recurrent: true
  end

  def amount
    PLAN_TYPE_PRICES[self.plan_type]
  end

  def frequency
    PLAN_TYPE_FREQUENCY[self.plan_type]
  end

  def canceled?
    self.canceled_at.present?
  end

  def active?
    !canceled? and self.expires_at > Date.today
  end
end
