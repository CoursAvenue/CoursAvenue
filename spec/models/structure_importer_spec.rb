require 'rails_helper'

describe StructureImporter do
  let(:file) { fixture_file_upload('files/structures.csv', 'text/csv') }

  describe '.initialize' do
    it do
      importer = StructureImporter.new(file)
      expect(importer.file).to eq(file)
    end
  end

  describe '#import' do
    subject { StructureImporter.new(file) }

    context 'when the file is valid' do
      let(:existing_structure)  { FactoryGirl.create(:structure) }
      let(:new_structure)       { FactoryGirl.build(:structure) }
      let(:structure_to_delete) { FactoryGirl.create(:structure) }
      before do
        allow(CSV).to receive(:read).and_return([
          structure_to_csv(existing_structure),
          structure_to_csv(new_structure),
          structure_to_csv(structure_to_delete, true)
        ])
      end

      it 'imports the new structures' do
        expect { subject.import! }.to change { Structure.count }.by(1)
      end

      it 'updates the existing structures' do
        original_name = existing_structure.name
        subject.import!
        existing_structure.reload

        expect(existing_structure.name).to_not eq(original_name)
      end

      it 'deleted the other structures' do
      end
    end
  end

  def structure_to_csv(structure, to_delete = false)
    [
      structure.subjects.map.join(' | '),
      structure.name,
      pro_structures_path(structure),
      structure.website,
      structure.contact_phone
    ].map(&:to_s)
  end
end
