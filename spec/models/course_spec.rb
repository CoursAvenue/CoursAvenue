# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Course do
  let(:workshop)          { FactoryGirl.build(:workshop) }
  let(:training)          { FactoryGirl.build(:training) }
  let(:lesson)            { FactoryGirl.build(:lesson) }

  before(:all) do
    @course        = FactoryGirl.create(:course)
    @price_1       = @course.prices.build FactoryGirl.attributes_for(:individual_price, amount: 15)
    @price_2       = @course.prices.build FactoryGirl.attributes_for(:annual_price, amount: 20)
    @planning_1    = FactoryGirl.create(:planning)
    @course.prices = [@price_1, @price_2]
    @course.save
  end

  subject {@course}
  it { should be_valid }

  describe '#copy_prices_from' do
    it 'duplicate all the prices from a given course' do
      # TODO
    end
  end

  describe '#best_price' do
    context 'without promotion' do
      it 'returns the price with lowest amount' do
        @course.best_price.should eq @price_1
      end
    end

    context 'with promotion' do
      before do @price_2.update_column(:promo_amount, 10) end
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
      @course = FactoryGirl.build(:course, active: false)
    end
    context 'without plannings' do
      context 'without prices' do
        it 'fails' do
          @course.activate!.should be_false
          @course.active.should be_false
          @course.errors[:prices].length.should eq 1
          @course.errors[:plannings].length.should eq 0
        end
      end
      context 'with prices' do
        before(:each) do
          @course.prices << @price_1
          @course.save
        end
        it 'activates' do
          @course.activate!.should be_true
          @course.active.should be_true
          @course.errors[:plannings].length.should eq 0
          @course.should have(0).errors_on(:prices)
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
          @course.errors[:prices].length.should eq 1
          @course.should have(0).errors_on(:plannings)
        end
      end
    end
    context 'with prices and plannings' do
      before(:each) do
        @course.plannings << @planning_1
        @course.prices    << @price_1
        @course.save
      end
      it 'activates' do
        @course.activate!.should be_true
        @course.active.should be_true
        @course.should have(0).errors_on(:plannings)
        @course.should have(0).errors_on(:prices)
      end
    end
  end
  # recent_plannings
  # has_package_price
  # has_trial_lesson
  # has_unit_course_price
  # time_slots
  # similar_courses(limit = 5)
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
      @course.slug.should_not be_nil
    end
    context :inactive do
      before do
        @course.active = false
      end
      it 'should change slug with name' do
        initial_slug = @course.slug
        @course.name += ' new slug'
        @course.save
        @course.slug.should_not eq initial_slug
      end
    end

    context :active do
      before do
        @course.active = true
      end
      it 'should keep same slug' do
        initial_slug = @course.slug
        @course.name += ' new slug'
        @course.save
        @course.slug.should eq initial_slug
      end
    end
  end


  context :duplicate do
    before(:all) do
      @course           = FactoryGirl.build(:course)
      @course.prices    << FactoryGirl.build(:annual_price)
      @course.plannings << FactoryGirl.build(:planning)
      @course_duplicate = @course.duplicate!
    end
    it 'keeps structure id' do
      @course_duplicate.structure_id.should eq @course_duplicate.structure_id
    end
    it 'keeps place' do
      @course_duplicate.place_id.should eq @course_duplicate.place_id
    end
    it 'keeps name with a prefix' do
      @course_duplicate.name.should include @course.name
    end
    it 'has same levels' do
      @course_duplicate.levels.should eq @course.levels
    end
    it 'has same audiences' do
      @course_duplicate.audiences.should eq @course.audiences
    end
    it 'has same subjects' do
      @course_duplicate.subjects.should eq @course.subjects
    end
    it 'has same prices' do
      @course_duplicate.prices.length.should eq @course.prices.length
    end
    it 'has same plannings' do
      @course_duplicate.plannings.length.should eq @course.plannings.length
    end
    it 'is inactive' do
      @course_duplicate.active?.should be_false
    end
    it 'is saved' do
      @course_duplicate.new_record?.should be_false
    end
  end
end
