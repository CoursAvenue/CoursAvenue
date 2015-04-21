FactoryGirl.define do
  factory :bloc, class: Newsletter::Bloc do
    newsletter

    type { Newsletter::Bloc::BLOC_TYPES.sample }

    factory :text_bloc do
      type 'Newsletter::Bloc::Text'
    end

    factory :image_bloc do
      type 'Newsletter::Bloc::Image'
    end

    factory :multi_bloc do
      type 'Newsletter::Bloc::Multi'
    end
  end
end
