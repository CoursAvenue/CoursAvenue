# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Course do

  context 'friendly_id' do
    it 'should not change the slug when the name change' do
      course = FactoryGirl.create(:course)
      initial_slug = course.slug
      course.name += ' new slug'
      course.save
      expect(initial_slug).not_to eq(nil)
      expect(initial_slug).to eq(course.slug)
    end
  end

  # ------------- Search tests

  it 'should return courses from given city' do
    course         = FactoryGirl.create(:course_at_paris)
    courses_result = Course.from_city(FactoryGirl.build(:city_paris).short_name)
    expect(courses_result).to include(course)

    # structure      = course.structure
    # structure.city = FactoryGirl.create(:nice)
    # structure.save

  end


end
