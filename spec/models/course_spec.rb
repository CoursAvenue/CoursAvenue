# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Course do

  # it 'should be true' do
  #   FactoryGirl.build(:course)
  # end

  it 'should not change the slug when the name change' do
    course = FactoryGirl.build(:course)
    initial_slug = course.slug
    course.name += ' lala'
    course.save
    expect(initial_slug).to eq(course.slug)
  end


end
