FactoryGirl.define do
  factory :guide_answer, :class => 'Guide::Answer' do
    guide nil
guide_question nil
content "MyString"
  end

end
