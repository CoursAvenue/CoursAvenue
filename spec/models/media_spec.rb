# -*- encoding : utf-8 -*-
require 'rails_helper'

describe Media do

  describe '#video?' do
    it 'is true' do
      expect(Media::Video.new.video?).to be(true)
    end
    it 'is false' do
      expect(Media::Image.new.video?).to be(false)
    end
  end

  describe '#image?' do
    it 'is true' do
      expect(Media::Image.new.image?).to be(true)
    end
    it 'is false' do
      expect(Media::Video.new.image?).to be(false)
    end
  end
end
