FactoryGirl.define do
  factory :gift_certificate_voucher, :class => 'GiftCertificate::Voucher' do
    gift_certificate
    user
    gifted_to { Faker::Internet.email }
  end
end
