# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Planning do
  let(:planning) { Planning.new }

  # context :multiple_slots do
  #   let(:lesson)   { FactoryGirl.create(:lesson) }
  #   it 'creates multiple plannings' do
  #     lesson.plannings.create( start_time: Time.parse("2000-01-01 10:00 UTC"),
  #                               end_time: Time.parse("2000-01-01 12:00 UTC"),
  #                               duration: 60)
  #     lesson.plannings.length.should eq 2
  #   end
  # end

  context :audiences do
    describe '#audience_ids' do
      it 'returns array if nil' do
        planning.audience_ids = nil
        planning.audience_ids.should eq []
      end

      it 'has adult by default' do
        planning.audience_ids.should include Audience::ADULT.id
      end
    end
    describe '#audience_ids=' do
      it 'can affects by equals' do
        planning.audience_ids = [Audience::KID.id]
        planning.audience_ids.should include Audience::KID.id
      end
    end
    describe '#audiences=' do
      it 'can affects by equals' do
        planning.audiences = [Audience::KID]
        planning.audiences.should include Audience::KID
      end
    end
  end

  context :levels do
    describe '#level_ids' do
      it 'returns array if nil' do
        planning.level_ids = nil
        planning.level_ids.should eq []
      end

      it 'returns an array' do
        planning.level_ids.should eq []
      end
    end
    describe '#level_ids=' do
      it 'can affects by equals' do
        planning.level_ids = [Level::BEGINNER.id]
        planning.level_ids.should include Level::BEGINNER.id
      end
    end
    describe '#levels=' do
      it 'can affects by equals' do
        planning.levels = [Level::BEGINNER]
        planning.levels.should include Level::BEGINNER
      end
    end
  end
end
