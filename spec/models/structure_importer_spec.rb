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
    subject         { StructureImporter.new(file) }
    let(:structure) { FactoryGirl.create(:structure) }

    before do
      stub_csv
    end

    it 'updates the existing structure' do
      subject.import!
    end
  end

  def stub_csv
    allow(CSV).to receive(:read).and_return([
      structure_to_csv(structure)
    ])
  end

  def structure_to_csv(structure, status = 'C')
    [
      status: status,
      subject_3: structure.subjects.at_depth(3).join('|'),
      parisian: true
    ].map(&:to_s)
  end
end
