# -*- encoding : utf-8 -*-
require 'spec_helper'

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

  context :image do
    describe '#url_html' do
      it 'has src attribute' do
        expect(Media::Image.new.url_html).to include 'src='
      end
      context :lazy do
        it 'does not have src attribute' do
          expect(Media::Image.new.url_html(lazy: true)).not_to include 'src='
        end
      end
    end
  end

  context :video do
  end
end
