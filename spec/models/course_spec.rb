# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Course do
  let(:training)          { FactoryGirl.build(:training) }
  let(:lesson)            { FactoryGirl.build(:lesson) }

  before(:all) do
    @course                = FactoryGirl.create(:course)
    @price_1               = FactoryGirl.create(:price, amount: 15)
    @price_2               = FactoryGirl.create(:subscription, amount: 200)
    @planning_1            = FactoryGirl.create(:planning)
    @price_group           = FactoryGirl.build(:price_group)
    @price_group.prices    = [@price_1, @price_2]
    @price_group.structure = @course.structure
    @price_group.save
    @course.price_group = @price_group
    @course.save
  end

  subject {@course}
  it { should be_valid }

  describe '#best_price' do
    context 'without promotion' do
      it 'returns the price with lowest amount' do
        @course.best_price.should eq @price_1
      end
    end

    context 'with promotion' do
      before { @price_2.update_column(:promo_amount, 10) }
      # after  do @price_2.update_column(:promo_amount, nil) end
      it 'returns the price with lowest amount taking count of promotion' do
        @course.best_price.should eq @price_2
      end
    end
  end
  describe '#has_promotion?' do
    it{ @course.has_promotion?.should be_false }
    context 'with promo' do
      before do @price_2.update_column(:promo_amount, 10) end
      after  do @price_2.update_column(:promo_amount, nil) end
      it { @course.has_promotion?.should be_true }
    end
  end

  describe '#min_price' do
    it 'returns the lowest price' do
      @course.min_price.should eq @price_1.amount
    end
    context 'nil' do
      it 'should return nil' do
        course = FactoryGirl.create(:course)
        course.min_price.should be_nil
      end
    end
    context 'with promo' do
      before do @price_2.update_column(:promo_amount, 10) end
      after  do @price_2.update_column(:promo_amount, nil) end
      it 'returns the promo price' do
        @course.min_price.should eq @price_2.promo_amount
      end
    end
  end
  describe '#max_price' do
    it 'returns the highest price' do
      @course.max_price.should eq @price_2.amount
    end
    context 'nil' do
      it 'should return nil' do
        course = FactoryGirl.create(:course)
        course.max_price.should be_nil
      end
    end
  end

  describe '#activate!' do
    before(:each) do
      @course      = FactoryGirl.build(:course, active: false)
      @price_group = FactoryGirl.build(:price_group)
    end
    context 'without plannings' do
      context 'without prices' do
        it 'fails' do
          expect(@course.activate!).to be(false)
          expect(@course.active).to be(false)
          expect(@course.errors[:price_group].length).to eq 1
          expect(@course.errors[:plannings].length).to eq 1
        end
      end
      context 'with prices' do
        before(:each) do
          @course.price_group = @price_group
          @course.save
        end
        it 'activates' do
          @course.activate!.should be_false
          @course.active.should be_false
          @course.errors[:plannings].length.should eq 1
          @course.should have(0).errors_on(:price_group)
        end
      end
    end
    context 'without prices' do
      context 'with plannings' do
        before(:each) do
          @course.plannings << @planning_1
          @course.save
        end
        it 'fails' do
          @course.activate!.should be_false
          @course.active.should be_false
          @course.errors[:price_group].length.should eq 1
          @course.should have(0).errors_on(:plannings)
        end
      end
    end
    context 'with prices and plannings' do
      before(:each) do
        @course.plannings << @planning_1
        @course.price_group = @price_group
        @course.save
      end
      it 'activates' do
        @course.activate!.should be_true
        @course.active.should be_true
        @course.should have(0).errors_on(:plannings)
        @course.should have(0).errors_on(:price_group)
      end
    end
  end
  # Methods to test
  # recent_plannings
  # has_package_price
  # has_trial_lesson
  # has_unit_course_price
  # time_slots
  # promotion_planning
  # is_for_kid
  # has_multiple_teacher?
  # has_teacher?
  # promotion
  # promotion_price
  # approximate_price_per_course
  # type_name
  # should_generate_new_friendly_id?
  # description_for_input
  # friendly_name
  # set_structure_if_empty
  # replace_slash_n_r_by_brs

  context 'lesson' do
    subject { lesson }
    it 'is a lesson' do
      lesson.is_lesson?.should be_true
    end
    it 'is not a training' do
      lesson.is_training?.should be_false
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
  end

  context 'friendly_id' do
    it 'should have slug' do
      @course.slug.should_not be_nil
    end

    it 'should keep same slug' do
      initial_slug = @course.slug
      @course.name += ' new slug'
      @course.save
      @course.slug.should eq initial_slug
    end
  end

  context 'open course' do
    before do
      @open_course = FactoryGirl.create(:open_course)
      planning     = FactoryGirl.create(:planning)
      user         = FactoryGirl.create(:user)
      participation = Participation.create user: user, planning: planning
      planning.participations<< participation
      planning.save
      @open_course.plannings << planning
      @open_course.save
    end
  end
end
