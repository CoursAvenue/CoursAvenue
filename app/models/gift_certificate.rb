class GiftCertificate < ActiveRecord::Base
  acts_as_paranoid

  MIN_AMOUNT = 0

  attr_accessible :name, :amount, :description

  belongs_to :structure
  # has_many :vouchers, class_name: 'GiftCertificate::Voucher'

  validates :name,        presence: true
  validates :amount,      presence: true, numericality: { greater_than: MIN_AMOUNT }
  validates :description, presence: true
end
