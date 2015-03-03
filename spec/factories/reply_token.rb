FactoryGirl.define do
  factory :reply_token do
    reply_type 'participation_request'
    token { Faker::Internet.password }

    after :build do |reply_token|
      participation_request = FactoryGirl.create(:participation_request)
      reply_token.participation_request_id = participation_request.id
    end
  end
end
