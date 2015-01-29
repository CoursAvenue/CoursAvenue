# -*- encoding : utf-8 -*-
require 'rails_helper'

describe ParticipationRequest do

  subject { ParticipationRequest.new }

  describe '#past?' do
    it 'returns true' do
      subject.date = Date.yesterday
      expect(subject.past?).to eq true
    end

    it 'returns false' do
      subject.date = Date.tomorrow
      expect(subject.past?).to eq false
    end
  end

end
