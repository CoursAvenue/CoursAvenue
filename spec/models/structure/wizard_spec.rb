# -*- encoding : utf-8 -*-
require 'rails_helper'

describe Structure::Wizard do
  let (:structure) { FactoryGirl.build(:structure) }

  describe '#description' do
    let (:description_wizard) { Structure::Wizard.where(name: 'wizard.description').first }
    context :empty do
      it 'is not completed' do
        structure.description = ''
        expect(description_wizard.completed?.call(structure)).to be(false)
      end
    end

    context :filled do
      it 'is completed' do
        structure.description = 'lorem azdojaz pdojazd paozjd apzodjzap dojazpdoja zdpoazj p'
        expect(description_wizard.completed?.call(structure)).to be(true)
      end
    end
  end

  describe '#places' do
    let (:places_wizard) { Structure::Wizard.where(name: 'wizard.places').first }
    context :has_only_one_place? do
      it 'is completed' do
        structure.has_only_one_place = true
        expect(places_wizard.completed?.call(structure)).to be(true)
      end
    end

    context :has_filled_more_than_one_places? do
      it 'is completed' do
        structure.places << FactoryGirl.create(:place, structure: structure)
        structure.places << FactoryGirl.create(:place, structure: structure)
        expect(places_wizard.completed?.call(structure)).to be(true)
      end
    end

    context :has_one_place_but_has_only_one_place_is_not_filled do
      it 'is not completed' do
        structure.has_only_one_place = false
        expect(places_wizard.completed?.call(structure)).to be(false)
      end
    end
  end

  describe '#recommendations' do
    let (:recommendations_wizard) { Structure::Wizard.where(name: 'wizard.recommendations').first }

    context :has_no_recommandations do
      it 'is not completed' do
        expect(recommendations_wizard.completed?.call(structure)).to be(false)
      end
    end

    context :has_comments_notifications do
      it 'is completed' do
        structure.comment_notifications.build
        expect(recommendations_wizard.completed?.call(structure)).to be(true)
      end
    end
    context :has_at_least_one_recommandation do
      it 'is completed' do
        structure.comments.build
        expect(recommendations_wizard.completed?.call(structure)).to be(true)
      end
    end
  end
end
