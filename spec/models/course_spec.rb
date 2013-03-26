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
      @paris     = City.where{name == 'Paris'}.first
    end
  end
  describe :create do
    context 'on save' do
      course = FactoryGirl.build(:course)
      expect(course.place).to_be nil
      # course.save
      # expect(course.place_id).to eq course.room.place_id
    end
  end
end
