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

  # describe '#logo' do
  #   let (:logo_wizard) { Structure::Wizard.where(name: 'wizard.logo').first }
  #   context :empty do
  #     it 'is not completed' do
  #       structure.logo = ''
  #       expect(logo_wizard.completed?.call(structure)).to be(false)
  #     end
  #   end

  #   context :filled do
  #     it 'is completed' do
  #       structure.logo = 'lorem azdojaz pdojazd paozjd apzodjzap dojazpdoja zdpoazj p'
  #       expect(logo_wizard.completed?.call(structure)).to be(true)
  #     end
  #   end
  # end

  # describe '#coordonates' do
  #   let (:coordonates_wizard) { Structure::Wizard.where(name: 'wizard.coordonates').first }
  #   context :empty do
  #     it 'is not completed' do
  #       structure.contact_phone = ''
  #       structure.contact_mobile_phone = ''
  #       expect(coordonates_wizard.completed?.call(structure)).to be(false)
  #     end
  #   end

  #   context :filled do
  #     it 'is completed' do
  #       structure.contact_phone = '02 14 01 41 32'
  #       expect(coordonates_wizard.completed?.call(structure)).to be(true)
  #     end
  #   end
  # end

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

  describe '#widget_status' do
    let (:widget_status_wizard) { Structure::Wizard.where(name: 'wizard.widget_status').first }

    context :has_less_than_five_recommandations do
      it 'is completed' do
        expect(widget_status_wizard.completed?.call(structure)).to be(true)
      end
    end
    context :has_more_than_five_recommandations do
      context 'widget_status is not defined' do
        it 'is not completed' do
          structure.widget_status = nil
          structure.comments_count = 6
          expect(widget_status_wizard.completed?.call(structure)).to be(false)
        end
      end
      context 'widget_status is defined' do
        it 'is not completed' do
          structure.widget_status = Structure::WIDGET_STATUS.last
          structure.comments_count = 6
          expect(widget_status_wizard.completed?.call(structure)).to be(true)
        end
      end
    end
  end

  describe '#widget_url' do
    let (:widget_url_wizard) { Structure::Wizard.where(name: 'wizard.widget_url').first }

    context :has_less_than_five_recommandations do
      it 'is completed' do
        expect(widget_url_wizard.completed?.call(structure)).to be(true)
      end
    end
    context :has_more_than_five_recommandations do
      context 'widget_status is set to installed and widget_url is not defined' do
        it 'is not completed' do
          structure.comments_count = 6
          structure.widget_status = 'installed'
          structure.widget_url = nil
          expect(widget_url_wizard.completed?.call(structure)).to be(false)
        end
      end
      context 'widget_status is defined' do
        it 'is not completed' do
          structure.widget_status = 'installed'
          structure.widget_url = 'http://lazdlaz.com'
          structure.comments_count = 6
          expect(widget_url_wizard.completed?.call(structure)).to be(true)
        end
      end
    end
  end
end
