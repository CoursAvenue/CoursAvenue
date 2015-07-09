require 'rails_helper'

describe Subject do

  context 'associations' do
    it { should have_and_belong_to_many(:guide_answers).class_name('Guide::Answer') }
    it { should have_and_belong_to_many(:indexable_cards) }
  end

  describe '#descendant_of?' do
    context 'by default' do
      subject { FactoryGirl.create(:subject) }

      let(:supposed_root) { FactoryGirl.create(:subject) }

      it "doesn't have any parent by default" do
        expect(subject.descendant_of?(supposed_root)).to be_falsy
      end
    end

    context 'has a parent' do
      subject      { FactoryGirl.create(:subject_with_parent) }
      let(:parent) { subject.parent }

      it { expect(subject.descendant_of?(parent)).to be_truthy }
      it { expect(subject.descendant_of?([parent])).to be_truthy }
    end

    context 'has grandparents' do
      subject            { FactoryGirl.create(:subject_with_grand_parent) }
      let(:parent)       { subject.parent }
      let(:grand_parent) { parent.parent }

      it { expect(subject.descendant_of?(parent)).to be_truthy }
      it { expect(subject.descendant_of?(grand_parent)).to be_truthy }
    end
  end

  describe '#little_children' do
    let(:child)  { FactoryGirl.create(:subject_with_grand_parent) }
    let(:parent) { child.parent }
    subject      { parent.parent }

    it { expect(subject.little_children).to include(child) }
    it { expect(child.little_children).to be_empty }
  end

  describe '#grand_parent' do
    subject             { FactoryGirl.create(:subject_with_grand_parent) }
    let!(:parent)       { subject.parent }
    let!(:grand_parent) { parent.parent }

    it { expect(subject.grand_parent).to eq(grand_parent) }
    it { expect(parent.grand_parent).to eq(grand_parent) }
    it { expect(grand_parent.grand_parent).to be_nil }
  end

  describe '#as_json' do
    subject { FactoryGirl.create(:subject) }
    it { expect(subject.as_json).to_not be_nil }
  end

  describe '#good_to_know' do
    context 'with meterial' do
      subject { FactoryGirl.create(:subject, :with_good_to_know) }

      it 'returns the meterial' do
        expect(subject.good_to_know).to_not be_nil
      end
    end

    context 'without meterial' do
      context 'with a parent' do
        subject      { FactoryGirl.create(:subject) }
        let(:parent) { FactoryGirl.create(:subject, :with_good_to_know) }

        before do
          subject.parent = parent
          subject.save
        end

        it 'returns the parent meterial' do
          expect(subject.good_to_know).to eq(parent.good_to_know)
        end
      end

      context 'without parent' do
        subject { FactoryGirl.create(:subject) }
        it { expect(subject.good_to_know).to be_nil }
      end
    end
  end

  describe '#needed_meterial' do
    context 'with meterial' do
      subject { FactoryGirl.create(:subject, :with_needed_meterial) }

      it 'returns the meterial' do
        expect(subject.needed_meterial).to_not be_nil
      end
    end

    context 'without meterial' do
      context 'with a parent' do
        subject      { FactoryGirl.create(:subject) }
        let(:parent) { FactoryGirl.create(:subject, :with_needed_meterial) }

        before do
          subject.parent = parent
          subject.save
        end

        it 'returns the parent meterial' do
          expect(subject.needed_meterial).to eq(parent.needed_meterial)
        end
      end

      context 'without parent' do
        subject { FactoryGirl.create(:subject) }
        it { expect(subject.needed_meterial).to be_nil }
      end
    end
  end

  describe '#tips' do
    context 'with meterial' do
      subject { FactoryGirl.create(:subject, :with_tips) }

      it 'returns the meterial' do
        expect(subject.tips).to_not be_nil
      end
    end

    context 'without meterial' do
      context 'with a parent' do
        subject      { FactoryGirl.create(:subject) }
        let(:parent) { FactoryGirl.create(:subject, :with_tips) }

        before do
          subject.parent = parent
          subject.save
        end

        it 'returns the parent meterial' do
          expect(subject.tips).to eq(parent.tips)
        end
      end

      context 'without parent' do
        subject { FactoryGirl.create(:subject) }
        it { expect(subject.tips).to be_nil }
      end
    end
  end
end
