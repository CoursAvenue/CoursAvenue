require 'rails_helper'

describe User::Favorite do
  context 'validations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:structure) }
    it { is_expected.to belong_to(:indexable_card) }
  end
end
