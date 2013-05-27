# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Course do
  subject {course}
  let(:course)   { FactoryGirl.create(:course) }
  let(:workshop) { FactoryGirl.build(:workshop) }
  let(:training) { FactoryGirl.build(:training) }
  let(:lesson)   { FactoryGirl.build(:lesson) }

  it { should be_valid }

  describe '#best_price' do
    let(:price_1)          { FactoryGirl.create(:individual_price, amount: 15) }
    let(:price_2)          { FactoryGirl.create(:annual_price, amount: 20) }
    before do
      course.prices << [price_1, price_2]
    end
    context 'without promotion' do
      it 'returns the price with lowest amount' do
        course.best_price.should eq price_1
      end
    end

    context 'with promotion' do
      before do
        price_2.promo_amount = 10
        price_2.save
      end
      it 'returns the price with lowest amount taking count of promotion' do
        course.best_price.should eq price_2
      end
    end
  end
  # has_promotion

  # recent_plannings
  # has_no_price
  # has_package_price
  # has_trial_lesson
  # has_unit_course_price
  # min_price
  # max_price
  # time_slots
  # similar_courses(limit = 5)
  # promotion_planning
  # is_for_kid
  # has_multiple_teacher?
  # has_teacher?
  # promotion
  # promotion_price
  # slug_type_name
  # approximate_price_per_course
  # type_name
  # should_generate_new_friendly_id?
  # description_for_input
  # activate!
  # friendly_name
  # set_structure_if_empty
  # replace_slash_n_r_by_brs

  context 'workshop' do
    subject { workshop }
    it 'is a workshop' do
      workshop.is_workshop?.should be_true
    end
    it 'is not a lesson' do
      workshop.is_lesson?.should be_false
    end
    it 'is not a training' do
      workshop.is_training?.should be_false
    end
  end

  context 'lesson' do
    subject { lesson }
    it 'is a lesson' do
      lesson.is_lesson?.should be_true
    end
    it 'is not a training' do
      lesson.is_training?.should be_false
    end
    it 'is not a workshop' do
      lesson.is_workshop?.should be_false
    end
  end

  context 'training' do
    subject { training }
    it 'is a training' do
      training.is_training?.should be_true
    end
    it 'is not a lesson' do
      training.is_lesson?.should be_false
    end
    it 'is not a workshop' do
      training.is_workshop?.should be_false
    end
  end

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
