require 'rails_helper'

shared_examples_for 'HasAudiencesAndLevels' do
  let (:model) { described_class }

  it 'is for kids' do
    model.audiences << Audience::KID

    expect(model.for_kid?).to be_truthy
  end

  it 'is for adults' do
    model.audiences << Audience::ADULT

    expect(model.for_adult?).to be_truthy
  end

  it 'is for seniors' do
    model.audiences << Audience::SENIOR

    expect(model.for_senior?).to be_truthy
  end
end
