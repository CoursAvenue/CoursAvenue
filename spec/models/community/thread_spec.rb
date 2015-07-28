require 'rails_helper'

RSpec.describe Community::Thread, type: :model do
  context 'associations' do
    it { should belong_to(:community) }
  end
end
