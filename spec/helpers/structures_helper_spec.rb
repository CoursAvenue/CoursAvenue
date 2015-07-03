require 'rails_helper'

describe StructuresHelper do
  describe '#little_children_subjects' do
    context 'when the structure has children of depth 2' do
      let(:child_subjects) { [ FactoryGirl.create(:subject_children),
                               FactoryGirl.create(:subject_children) ] }
      let(:subjects)  { child_subjects.map(&:root) + child_subjects }
      let(:structure) { FactoryGirl.create(:structure, subjects: subjects) }

      it 'returns only the little children' do
        expect(helper.little_children_subjects(structure)).to match_array(child_subjects)
      end
    end

    context "when the structure doesn't have any children of depth 2" do
      let(:child_subjects) { [ FactoryGirl.create(:subject_children),
                               FactoryGirl.create(:subject_children) ] }
      let(:subjects)  { child_subjects.map(&:root) }
      let(:structure) {
        structure = FactoryGirl.build(:structure, subjects: subjects)
        structure.save(validate: false)
        structure
      }

      it 'returns the little children of the roots it has' do
        expect(helper.little_children_subjects(structure)).to match_array(child_subjects)
      end
    end
  end
end
