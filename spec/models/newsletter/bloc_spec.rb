require 'rails_helper'

RSpec.describe Newsletter::Bloc, type: :model do
  # it { should belong_to(:newsletter) }
  it { should validate_presence_of(:type) }
  it { should validate_uniqueness_of(:position).scoped_to(:newsletter_id) }

  describe 'defaults' do
    let!(:newsletter) { FactoryGirl.create(:newsletter) }

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
end
