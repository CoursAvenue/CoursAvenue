# -*- encoding : utf-8 -*-
FactoryGirl.define do

  factory :subject do
    name Faker::Name.name

    factory :subject_children do
      name Faker::Name.name + ' child'

      after :build do |subject|
        subject_grand_parent   = Subject.create(name: Faker::Name.name)
        subject_parent         = subject_grand_parent.children.create(name: Faker::Name.name)
        subject.parent         = subject_parent
        subject.ancestry_depth = 2
      end
    end
  end
end
