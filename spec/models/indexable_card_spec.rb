require 'rails_helper'

RSpec.describe IndexableCard, type: :model do
  context 'associations' do
    it { should belong_to(:structure) }
    it { should belong_to(:place) }
    it { should belong_to(:course) }
    it { should have_many(:plannings) }
    it { should have_and_belong_to_many(:subjects) }
  end

  context 'delegations' do
    it { should delegate_method(:name).to(:course).with_prefix }
    it { should delegate_method(:audiences).to(:course).with_prefix }
    it { should delegate_method(:price).to(:course).with_prefix }
    it { should delegate_method(:type).to(:course).with_prefix }
    it { should delegate_method(:levels).to(:course).with_prefix }

    it { should delegate_method(:name).to(:structure).with_prefix }
    it { should delegate_method(:comments_count).to(:structure).with_prefix }
    it { should delegate_method(:slug).to(:structure).with_prefix }

    it { should delegate_method(:name).to(:place).with_prefix }
    it { should delegate_method(:latitude).to(:place).with_prefix }
    it { should delegate_method(:longitude).to(:place).with_prefix }
    it { should delegate_method(:address).to(:place).with_prefix }
  end

  let!(:structure) { FactoryGirl.create(:structure_with_multiple_place) }

  # describe '.create_from_course' do
  #   let!(:_subject)           { structure.subjects.sample }
  #   let!(:place_1)            { structure.places.first }
  #   let!(:place_2)            { structure.places.last }
  #   let!(:course)             { FactoryGirl.create(:course, structure: structure) }
  #   let!(:planning_place_1)   { FactoryGirl.create(:planning, course: course, place: place_1) }
  #   let!(:planning_place_2)   { FactoryGirl.create(:planning, course: course, place: place_2) }
  #   let!(:planning_2_place_2) { FactoryGirl.create(:planning, course: course, place: place_2) }
  #
  #   before do
  #     course.plannings.reload
  #   end
  #
  #   it 'creates two new IndexableCard' do
  #     expect { IndexableCard.create_from_course(course) }.
  #       to change { IndexableCard.count }.by(2)
  #   end
  #
  #   it 'associates it with the course' do
  #     cards = IndexableCard.create_from_course(course)
  #     expect(cards.map(&:course).uniq).to include(course)
  #   end
  #
  #   it 'sets the other associations' do
  #     card = IndexableCard.create_from_course(course).first
  #     expect(card.structure).to eq(structure)
  #     expect([place_1, place_2]).to include(card.place)
  #     expect(card.course).to eq(course)
  #     expect(card.subjects.uniq).to match_array(course.subjects)
  #   end
  #
  #   # TODO: Move this test to Planning
  #   # context 'when a planning is destroyed' do
  #   #   it 'destroys the card if there is no other plannings attached to it' do
  #   #     card = planning_place_1.indexable_card
  #   #     planning_place_1.destroy
  #   #     expect(card.persisted?).to be_falsy
  #   #   end
  #   # end
  #
  #   context 'when the card already exists' do
  #     it "doesn't create a new card" do
  #       IndexableCard.create_from_course(course)
  #       expect { IndexableCard.create_from_course(course) }.
  #         to_not change { IndexableCard.count }
  #     end
  #
  #     it 'returns the existing cards' do
  #       original_cards = IndexableCard.create_from_course(course)
  #       expect(IndexableCard.create_from_course(course)).to eq(original_cards)
  #     end
  #   end
  # end

  # describe '.create_from_place' do
  #   let(:place)    { structure.places.sample }
  #
  #   it 'creates a new IndexableCard' do
  #     expect { IndexableCard.create_from_place(place) }.
  #       to change { IndexableCard.count }.by(1)
  #   end
  #
  #   it 'associates with the structure' do
  #     card = IndexableCard.create_from_place(place)
  #     expect(card.structure).to eq(structure)
  #   end
  #
  #   it 'sets the other association' do
  #     card = IndexableCard.create_from_place(place)
  #     expect(card.place).to eq(place)
  #   end
  #
  #   context 'when the card already exists' do
  #     it "doesn't create a new card" do
  #       IndexableCard.create_from_place(place)
  #       expect { IndexableCard.create_from_place(place) }.
  #         to_not change { IndexableCard.count }
  #     end
  #
  #     it 'returns the existing card' do
  #       original_card = IndexableCard.create_from_place(place)
  #       expect(IndexableCard.create_from_place(place)).to eq(original_card)
  #     end
  #   end
  # end

  describe '#subject_name' do
    let!(:planning) { FactoryGirl.create(:planning) }
    let!(:course)    { planning.course }
    subject { IndexableCard.create_from_course(course).first }

    it 'returns the name of the first subject' do
      course.reload
      expect(subject.subject_name).to eq(subject.subjects.first.name)
    end
  end

  describe '#weekly_availability' do
    context 'when there is no course' do
      let!(:place) { structure.places.sample }
      subject { IndexableCard.create_from_place(place) }

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
      subject { IndexableCard.create_from_course(course).first }

      it 'returns the daily count of the plannings' do
        course.reload
        expected_aval = [
          { day: 'monday',    count: 1 },
          { day: 'tuesday',   count: 1 },
          { day: 'wednesday', count: 1 },
          { day: 'thursday',  count: 1 },
          { day: 'friday',    count: 0 },
          { day: 'saturday',  count: 0 },
          { day: 'sunday',    count: 0 }
        ]

        get_count = lambda { |day| day[:count] }

        expect(subject.weekly_availability.map(&get_count)).to eq(expected_aval.map(&get_count))
      end
    end
  end

  describe '#planning_periods' do
    context 'when there is no course' do
      let!(:place) { structure.places.sample }
      subject { IndexableCard.create_from_place(place) }

      it 'returns an empty array' do
        expect(subject.planning_periods).to be_empty
      end
    end

    context 'when there is a course' do
      let!(:place) { structure.places.sample }
      let!(:course) { FactoryGirl.create(:course, structure: structure) }
      let(:start_time) { DateTime.now.change({ hour: 9 }) }
      let(:end_time)   { DateTime.now.change({ hour: 11 }) }
      let!(:planning)  { FactoryGirl.create(:planning, course: course, place: place, week_day: 1, start_time: start_time, end_time: end_time) }
      let!(:planning2) { FactoryGirl.create(:planning, course: course, place: place, week_day: 2, start_time: start_time, end_time: end_time) }
      let!(:planning3) { FactoryGirl.create(:planning, course: course, place: place, week_day: 3, start_time: start_time, end_time: end_time) }
      let!(:planning4) { FactoryGirl.create(:planning, course: course, place: place, week_day: 4, start_time: start_time, end_time: end_time) }
      let!(:planning5) { FactoryGirl.create(:planning, course: course, place: place, week_day: 4, start_time: start_time, end_time: end_time) }
      subject { IndexableCard.create_from_course(course).first }

      it 'returns the daily count of the plannings' do
        course.reload
        expected_aval = [ "monday-morning", "tuesday-morning", "wednesday-morning",
                          "thursday-morning" ]

        expect(subject.planning_periods).to match_array(expected_aval)
      end
    end

  end

  describe '#starting_price' do
    context 'when there are prices' do
      let!(:place) { structure.places.sample }
      let!(:course) { FactoryGirl.create(:course, structure: structure) }
      let!(:planning) { FactoryGirl.create(:planning, course: course, place: place) }
      subject { IndexableCard.create_from_course(course).first }

      it 'returns the lowest price of the course' do
        course.reload
        expected_starting_price = course.prices.order('amount ASC').first.amount.to_f
        expect(subject.starting_price).to eq(expected_starting_price)
      end
    end

    context 'when there are no prices' do
      let!(:place) { structure.places.sample }
      subject { IndexableCard.create_from_place(place) }

      it 'returns 0' do
        expect(subject.starting_price).to eq(0)
      end
    end
  end

  describe '#card_type' do
    context 'when the course is a training' do
      it 'returns training'
    end

    context 'when the course is not a training' do
      it 'returns course'
    end

    context 'when there are no courses' do
      it 'returns course'
    end
  end

  describe '#toggle_favorite!' do
    let(:subject) { FactoryGirl.create(:indexable_card) }
    let(:user) { FactoryGirl.create(:user) }

    context 'when the card is not a favorite' do
      it 'creates a new user favorite' do
        expect { subject.toggle_favorite!(user) }. to change { user.reload.favorites.count }.by(1)
      end

      it { expect(subject.toggle_favorite!(user)).to be_truthy }
    end

    context 'when the card is already a favorite' do
      before { subject.toggle_favorite!(user) }

      it 'destroys the favorite' do
        expect { subject.toggle_favorite!(user) }.to change { user.reload.favorites.count }.by(-1)
      end

      it { expect(subject.toggle_favorite!(user)).to be_falsy }
    end
  end
end
