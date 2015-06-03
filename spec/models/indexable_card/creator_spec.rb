require 'rails_helper'

describe IndexableCard::Creator do
  let(:structure) { FactoryGirl.create(:structure_with_place) }

  describe '#initialize' do
    it do
      creator = IndexableCard::Creator.new(structure)
      expect(creator.structure).to eq(structure)
    end
  end

  describe '#create_cards' do
    subject { IndexableCard::Creator.new(structure) }

    it 'creates new cards' do
      expect { subject.create_cards; structure.reload }.
        to change { structure.indexable_cards.count }
    end
  end

  describe '#update_cards' do
    subject { IndexableCard::Creator.new(structure) }

    context 'when there are no cards' do
      it 'creates new cards' do
        expect { subject.create_cards; structure.reload }.
          to change { structure.indexable_cards.count }
      end
    end

    context 'when there are cards' do
      let(:new_subject)  { FactoryGirl.create(:subject) }
      let(:new_course)   { FactoryGirl.create(:course, structure: structure) }
      let(:new_planning) { FactoryGirl.create(:planning, course: new_course) }
      let(:new_place)    { FactoryGirl.create(:place, structure: structure) }

      before do
        subject.create_cards
      end

      context "when there's a new planning" do
        before do
          new_planning
          structure.reload
        end

        it 'creates a new card' do
          expect { subject.update_cards }.
            to change { structure.indexable_cards.count }.by(1)
        end

        it 'associates the new card with the planning' do
          cards = subject.update_cards
          expect(cards.first.planning).to eq(new_planning)
        end
      end

      context "when there's a new subject" do
        before do
          structure.subjects << new_subject
          structure.reload
        end

        it 'creates a new card' do
          expect { subject.update_cards; structure.reload }.
            to change { structure.indexable_cards.count }.by(1)
        end

        it 'associates the new card with the subject' do
          cards = subject.update_cards
          expect(cards.first.subjects).to include(new_subject)
        end
      end

      context "when there's a new place" do
        before do
          structure.places << new_place
          structure.reload
        end

        it 'creates a new card' do
          expect { subject.update_cards }.
            to change { structure.indexable_cards.count }.by(1)
        end

        it 'associates the new card with the place' do
          cards = subject.update_cards
          expect(cards.first.place).to eq(new_place)
        end
      end
    end
  end
end
