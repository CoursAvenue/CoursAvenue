# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Course do
  subject {course}
  let(:course) { FactoryGirl.create(:course) }

  it { should be_valid }

  context 'friendly_id' do
    it 'should have slug' do
      course.slug.should_not be_nil
    end

    it 'should change slug with name' do
      initial_slug = course.slug
      course.name += ' new slug'
      course.save
      course.slug.should_not eq initial_slug
    end
  end

end
