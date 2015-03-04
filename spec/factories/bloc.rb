FactoryGirl.define do
  factory :bloc, class: Newsletter::Bloc do
    newsletter

    type { Newsletter::Bloc::BLOC_TYPES.sample }

    factory :text_bloc do
      type 'text'
    end

    factory :image_bloc do
      type 'image'
    end
  end
end
