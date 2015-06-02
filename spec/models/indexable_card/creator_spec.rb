require 'rails_helper'

describe IndexableCard::Creator do
  let(:structure) { FactoryGirl.create(:structure) }

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
  end
end
