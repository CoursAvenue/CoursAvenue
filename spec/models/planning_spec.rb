# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Planning do

  context :initialization do
    it 'has default values' do
      subject.audiences.should include Audience::ADULT
      subject.levels.should    include Level::ALL
    end
  end

  context :callbacks do
    describe '#set end_date' do
      it 'sets end_date same as start_date if training' do
        course             = Course::Training.new
        subject.start_date = Date.yesterday
        subject.course     = course
        subject.send :set_end_date
        expect(subject.end_date).to eq Date.yesterday
      end
      it 'sets end_date same as course if present' do
        course         = Course::Lesson.new end_date: Date.yesterday
        subject.course = course
        subject.send :set_end_date
        expect(subject.end_date).to eq Date.yesterday
      end
    end

    describe '#set start_date' do
      it 'sets start_date regarding course' do
        course         = Course::Lesson.new start_date: Date.yesterday, end_date: Date.tomorrow
        subject.course = course
        subject.send :set_start_date
        expect(subject.start_date).to eq Date.yesterday
      end
    end

    describe '#update_start_and_end_date' do
      it 'sets start and end_date automatically' do
        course         = Course::Lesson.new start_date: Date.yesterday, end_date: Date.tomorrow
        subject.course = course
        subject.send :update_start_and_end_date
        expect(subject.start_date).to eq Date.yesterday
        expect(subject.end_date).to eq Date.tomorrow
      end

      it 'sets start and end_date even if defined' do
        course             = Course::Lesson.new start_date: Date.yesterday, end_date: Date.tomorrow
        subject.course     = course
        subject.start_date = Date.yesterday - 1.day
        subject.end_date   = Date.tomorrow + 1.day
        subject.send :update_start_and_end_date
        expect(subject.start_date).to eq Date.yesterday
        expect(subject.end_date).to eq Date.tomorrow
      end
    end
  end

  context :validations do
    describe '#presence_of_start_date' do
      it 'has error on start_date if in past' do
        course = Course::Training.new
        subject.course = course
        subject.stub(:start_date) { nil }
        subject.valid?
        expect(subject.errors.messages).to include :start_date
      end
    end

    describe '#end_date_in_future' do
      it 'has error on end_date if in past' do
        course = Course::Training.new
        subject.course = course
        subject.stub(:end_date) { Date.yesterday }
        subject.valid?
        expect(subject.errors.messages).to include :end_date
      end
    end

    describe '#presence_of_place' do
      it 'has error if place is not defined and not in foreign country' do
        course = Course::Training.new
        subject.course = course
        subject.stub(:place_id) { nil }
        subject.stub(:is_in_foreign_country) { false }
        subject.valid?
        expect(subject.errors.messages).to include :place_id
      end

      it 'has no error if place is not defined but in foreign country' do
        course = Course::Training.new
        subject.course = course
        subject.stub(:place_id) { nil }
        subject.stub(:is_in_foreign_country) { true }
        subject.valid?
        expect(subject.errors.messages).not_to include :place_id
      end
    end
    context :training do
      it 'needs a start_date' do
        course          = Course::Training.new
        subject.course = course
        expect(subject.valid?).to be(false)
        expect(subject.errors.messages).to include :start_date
      end
    end
    describe '#min_age_must_be_less_than_max_age' do
      context 'min_age_for_kid is more than max_age_for_kid' do
        it 'add errors to base' do
          subject.min_age_for_kid = 12
          subject.max_age_for_kid = 10
          subject.course = Course.new
          subject.valid? # To trigger validations
          expect(subject.errors.messages).to include :max_age_for_kid
        end
      end
    end
  end

  context :audiences do
    describe '#audience_ids' do
      it 'returns array if nil' do
        subject.audience_ids = nil
        subject.audience_ids.should eq []
      end
      it 'returns an array' do
        subject.audience_ids.class.should be Array
      end

      it 'has adult by default' do
        subject.audience_ids.should include Audience::ADULT.id
      end
    end
    describe '#audience_ids=' do
      it 'can affects by equals' do
        subject.audience_ids = [Audience::KID.id]
        subject.audience_ids.should include Audience::KID.id
      end
    end
    describe '#audiences=' do
      it 'can affects by equals' do
        subject.audiences = [Audience::KID]
        subject.audiences.should include Audience::KID
      end
    end
  end

  context :levels do
    describe '#level_ids' do
      it 'returns array if nil' do
        subject.level_ids = nil
        subject.level_ids.should eq []
      end

      it 'returns an array' do
        subject.level_ids.class.should be Array
      end
    end
    describe '#level_ids=' do
      it 'can affects by equals' do
        subject.level_ids = [Level::BEGINNER.id]
        subject.level_ids.should include Level::BEGINNER.id
      end
    end
    describe '#levels=' do
      it 'can affects by equals' do
        subject.levels = [Level::BEGINNER]
        subject.levels.should include Level::BEGINNER
      end
    end
  end

  describe '#nb_participants_max' do
    context 'nb_participants_max is not set' do
      it 'returns nb_participants_max' do
        subject.nb_participants_max = nil
        course                      = Course.new
        course.nb_participants_max  = 4
        subject.course              = course
        expect(subject.nb_participants_max).to eq 4
      end
    end
    context 'nb_participants_max is set' do
      it 'returns nb_participants_max' do
        subject.nb_participants_max = 12
        expect(subject.nb_participants_max).to eq 12
      end
    end
  end

  describe '#length' do
    it 'returns the week_day of the start_date' do
      start_date         = Date.today
      end_date           = Date.today + 4.days
      subject.start_date = start_date
      subject.end_date   = end_date
      expect(subject.length).to eq 5
    end
  end

  describe '#week_day' do
    context 'week_day is set' do
      it 'returns the week_day of the start_date' do
        date = Date.today
        subject.start_date = date
        expect(subject.week_day).to eq date.wday
      end
    end
    context 'no week_day set' do
      it 'returns week_day' do
        subject.week_day = 1
        expect(subject.week_day).to eq 1
      end
    end
  end

  context :participations do
    let(:user) { FactoryGirl.create(:user) }

    describe '#waiting_list' do
      it 'shows no one' do
        subject.nb_participants_max = 1
        subject.participations.build
        expect(subject.waiting_list).to be_empty
      end
    end
    describe '#places_left' do
      it 'returns number of participations left open' do
        planning = FactoryGirl.create(:planning, nb_participants_max: 10)
        Participation.create(waiting_list: true, user: user, planning: planning)
        expect(planning.places_left).to eq 9
      end
    end
  end
end
