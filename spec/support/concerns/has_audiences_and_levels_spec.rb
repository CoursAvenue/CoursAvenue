require 'rails_helper'

shared_examples_for 'HasAudiencesAndLevels' do
  let (:model)    { described_class }
  let (:instance) { FactoryGirl.create(model.to_s.underscore.to_sym) }

  it 'is for kids' do
    set_audience(instance, Audience::KID)

    expect(instance.for_kid?).to be_truthy
  end

  it 'is for adults' do
    set_audience(instance, Audience::ADULT)

    expect(instance.for_adult?).to be_truthy
  end

  it 'is for seniors' do
    set_audience(instance, Audience::SENIOR)

    expect(instance.for_senior?).to be_truthy
  end

  def set_audience(instance, audience)
    instance.audiences += [audience]

    instance.save
    instance.reload
  end
end
