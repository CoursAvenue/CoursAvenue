# -*- encoding : utf-8 -*-
FactoryGirl.define do

  factory :subject do
    name Forgery(:basic).password

    factory :subject_children do
      name Forgery(:basic).password + ' child'

      after :build do |subject|
        subject_grand_parent   = Subject.create(name: Forgery(:basic).password)
        subject_parent         = subject_grand_parent.children.create(name: Forgery(:basic).password)
        subject.parent         = subject_parent
        subject.ancestry_depth = 2
      end
    end
  end
end
