require 'rails_helper'

RSpec.describe IndexableCard, type: :model do
  context 'associations' do
    it { should belong_to(:structure) }
    it { should belong_to(:place) }
    it { should belong_to(:planning) }
    it { should belong_to(:course) }
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
      expect(card.subject).to eq(_subject)
      expect(card.place).to eq(place)
      expect(card.course).to eq(course)
      expect(card.planning).to eq(planning)
    end
  end

  describe '.create_from_subject_and_place' do
    let(:_subject) { structure.subjects.sample }
    let(:place)    { structure.places.sample }

    it 'creates a new IndexableCard' do
      expect { IndexableCard.create_from_subject_and_place(_subject, place) }.
        to change { IndexableCard.count }.by(1)
    end

    it 'associates with the structure' do
      card = IndexableCard.create_from_subject_and_place(_subject, place)
      expect(card.structure).to eq(structure)
    end
  end
end
