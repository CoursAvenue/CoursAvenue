require 'rails_helper'

RSpec.describe IndexableCard, type: :model do
  context 'associations' do
    it { should belong_to(:structure) }
    it { should belong_to(:place) }
    it { should belong_to(:planning) }
    it { should belong_to(:course) }
    it { should have_and_belong_to_many(:subjects) }
  end

  context 'delegations' do
    it { should delegate_method(:name).to(:course).with_prefix }
    it { should delegate_method(:price).to(:course).with_prefix }
    it { should delegate_method(:type).to(:course).with_prefix }

    it { should delegate_method(:name).to(:structure).with_prefix }
    it { should delegate_method(:comments_count).to(:structure).with_prefix }
    it { should delegate_method(:slug).to(:structure).with_prefix }

    it { should delegate_method(:name).to(:place).with_prefix }
    it { should delegate_method(:latitude).to(:place).with_prefix }
    it { should delegate_method(:longitude).to(:place).with_prefix }
    it { should delegate_method(:address).to(:place).with_prefix }
  end

  let!(:structure) { FactoryGirl.create(:structure) }

  describe '.create_from_planning' do
    let!(:_subject)  { structure.subjects.sample }
    let!(:place)     { structure.places.sample }
    let!(:course)    { FactoryGirl.create(:course, structure: structure) }
    let!(:planning)  { FactoryGirl.create(:planning, course: course, place: place) }

    it 'creates a new IndexableCard' do
      expect { IndexableCard.create_from_planning(planning) }.
        to change { IndexableCard.count }.by(1)
    end

    it 'associates it with the planning' do
      card = IndexableCard.create_from_planning(planning)
      expect(card.planning).to eq(planning)
    end

    it 'sets the other associations' do
      card = IndexableCard.create_from_planning(planning)
      expect(card.structure).to eq(structure)
      expect(card.place).to eq(place)
      expect(card.course).to eq(course)
      expect(card.planning).to eq(planning)
      expect(card.subjects).to match_array(planning.subjects)
    end

    context 'when the card already exists' do
      it "doesn't create a new card" do
        IndexableCard.create_from_planning(planning)
        expect { IndexableCard.create_from_planning(planning) }.
          to_not change { IndexableCard.count }
      end

      it 'returns the existing card' do
        original_card = IndexableCard.create_from_planning(planning)
        expect(IndexableCard.create_from_planning(planning)).to eq(original_card)
      end
    end
  end

  describe '.create_from_subject_and_place' do
    let(:_subject) { FactoryGirl.create(:subject) }
    let(:place)    { structure.places.sample }

    it 'creates a new IndexableCard' do
      expect { IndexableCard.create_from_subject_and_place(_subject, place) }.
        to change { IndexableCard.count }.by(1)
    end

    it 'associates with the structure' do
      card = IndexableCard.create_from_subject_and_place(_subject, place)
      expect(card.structure).to eq(structure)
    end

    it 'sets the other association' do
      card = IndexableCard.create_from_subject_and_place(_subject, place)
      expect(card.subjects).to include(_subject)
      expect(card.place).to eq(place)
    end

    context 'when the card already exists' do
      it "doesn't create a new card" do
        IndexableCard.create_from_subject_and_place(_subject, place)
        expect { IndexableCard.create_from_subject_and_place(_subject, place) }.
          to_not change { IndexableCard.count }
      end

      it 'returns the existing card' do
        original_card = IndexableCard.create_from_subject_and_place(_subject, place)
        expect(IndexableCard.create_from_subject_and_place(_subject, place)).to eq(original_card)
      end
    end
  end

  describe '#subject_name' do
    let!(:planning) { FactoryGirl.create(:planning) }
    subject! { IndexableCard.create_from_planning(planning) }

    it 'returns the name of the first subject' do
      expect(subject.subject_name).to eq(subject.subjects.first.name)
    end
  end

  describe '#weekly_availability' do
    context 'when there is no course' do
      let!(:_subject) { structure.subjects.sample }
      let!(:place) { structure.places.sample }
      subject { IndexableCard.create_from_subject_and_place(_subject, place) }

      it 'returns an empty array' do
        expect(subject.weekly_availability).to be_empty
      end
    end

    context 'when there is a course' do
      let!(:place) { structure.places.sample }
      let!(:course) { FactoryGirl.create(:course, structure: structure) }
      let!(:planning)  { FactoryGirl.create(:planning, course: course, place: place, week_day: 1) }
      let!(:planning2) { FactoryGirl.create(:planning, course: course, place: place, week_day: 2) }
      let!(:planning3) { FactoryGirl.create(:planning, course: course, place: place, week_day: 3) }
      let!(:planning4) { FactoryGirl.create(:planning, course: course, place: place, week_day: 4) }
      subject! { IndexableCard.create_from_planning(planning) }

      it 'returns the daily count of the plannings' do
        course.reload
        expected_aval = [
          { day: 'monday',    count: 1, letter: 'L' },
          { day: 'tuesday',   count: 1, letter: 'M' },
          { day: 'wednesday', count: 1, letter: 'M' },
          { day: 'thursday',  count: 1, letter: 'J' },
          { day: 'friday',    count: 0, letter: 'V' },
          { day: 'saturday',  count: 0, letter: 'S' },
          { day: 'sunday',    count: 0, letter: 'D' }
        ]

        expect(subject.weekly_availability).to eq(expected_aval)
      end
    end
  end

  describe '#starting_price' do
    context 'when there are prices' do
      let!(:place) { structure.places.sample }
      let!(:course) { FactoryGirl.create(:course, structure: structure) }
      let!(:planning) { FactoryGirl.create(:planning, course: course, place: place) }
      subject! { IndexableCard.create_from_planning(planning) }

      it 'returns the lowest price of the course' do
        expected_starting_price = course.prices.order('amount ASC').first.amount.to_f
        expect(subject.starting_price).to eq(expected_starting_price)
      end
    end

    context 'when there are no prices' do
      let!(:_subject) { structure.subjects.sample }
      let!(:place) { structure.places.sample }
      subject { IndexableCard.create_from_subject_and_place(_subject, place) }

      it 'returns 0' do
        expect(subject.starting_price).to eq(0)
      end
    end
  end
end
