require 'rails_helper'

RSpec.describe Community, type: :model do
  context 'association' do
    it { should belong_to(:structure) }
  end
end
