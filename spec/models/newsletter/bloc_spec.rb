require 'rails_helper'

RSpec.describe Newsletter::Bloc, type: :model do
  # it { should belong_to(:newsletter) }
  it { should validate_presence_of(:type) }
  it { should validate_uniqueness_of(:position).scoped_to(:newsletter_id) }

  let!(:newsletter) { FactoryGirl.create(:newsletter) }

  describe 'defaults' do

    before do
      5.times do |position|
        newsletter.blocs << FactoryGirl.create(:bloc, newsletter: newsletter)
      end
      newsletter.save
    end

    it 'sets the position by default' do
      bloc = FactoryGirl.create(:bloc, newsletter: newsletter)
      newsletter.blocs << bloc

      expect(bloc.position).to eq(newsletter.blocs.count)
    end
  end

  describe '#duplicate!' do
    subject                { FactoryGirl.create(:bloc, newsletter: newsletter) }
    let(:other_newsletter) { FactoryGirl.create(:newsletter) }

    it 'duplicates all of the attributes of the bloc' do
      duplicated_bloc = subject.duplicate!

      expect(duplicated_bloc.position).to eq(subject.position)
      expect(duplicated_bloc.type).to     eq(subject.type)
      expect(duplicated_bloc.content).to  eq(subject.content)
      # expect(duplicated_bloc.image).to    eq(subject.image)
    end
  end
end
