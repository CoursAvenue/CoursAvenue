# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Planning do
  let(:planning) { Planning.new }

  context :initialization do
    it 'has default values' do
      new_planning = Planning.new
      new_planning.audiences.should include Audience::ADULT
      new_planning.levels.should    include Level::ALL
    end
  end

  context :audiences do
    describe '#audience_ids' do
      it 'returns array if nil' do
        planning.audience_ids = nil
        planning.audience_ids.should eq []
      end
      it 'returns an array' do
        planning.audience_ids.class.should be Array
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
        planning.level_ids.class.should be Array
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

  context :duplication do
    it 'keeps audiences' do
      planning.audiences = [Audience::KID]
      duplicate          = planning.duplicate
      duplicate.audiences.should eq [Audience::KID]
    end
    it 'keeps levels' do
      planning.levels = [Level::BEGINNER]
      duplicate       = planning.duplicate
      duplicate.levels.should eq [Level::BEGINNER]
    end
    it 'keeps start_date' do
      planning.start_date = Date.tomorrow
      duplicate           = planning.duplicate
      duplicate.start_date.should eq Date.tomorrow
    end
    it 'keeps end_date' do
      planning.end_date   = Date.tomorrow
      duplicate           = planning.duplicate
      duplicate.end_date.should eq Date.tomorrow
    end
    it 'keeps start_time' do
      time                = Time.parse('13:37')
      planning.start_time = time
      duplicate           = planning.duplicate
      duplicate.start_time.should eq time
    end
    it 'keeps end_time' do
      time                = Time.parse('13:37')
      planning.end_time   = time
      duplicate           = planning.duplicate
      duplicate.end_time.should eq time
    end
    it 'keeps course reference' do
      duplicate           = planning.duplicate
      duplicate.course.should eq planning.course
    end
  end
end
