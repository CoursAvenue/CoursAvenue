class HarmonizedPriceLibelle < ActiveRecord::Migration
  def up
    Price.where{libelle == 'prices.annual'}.update_all libelle: 'prices.subscription.annual'
    Price.where{libelle == 'prices.semester'}.update_all libelle: 'prices.subscription.semester'
    Price.where{libelle == 'prices.trimester'}.update_all libelle: 'prices.subscription.trimester'
    Price.where{libelle == 'prices.month'}.update_all libelle: 'prices.subscription.month'

    Price.where{libelle == 'prices.student'}.update_all libelle: 'prices.promotion.student'
    Price.where{libelle == 'prices.young_and_senior'}.update_all libelle: 'prices.promotion.young_and_senior'
    Price.where{libelle == 'prices.job_seeker'}.update_all libelle: 'prices.promotion.job_seeker'
    Price.where{libelle == 'prices.low_income'}.update_all libelle: 'prices.promotion.low_income'
    Price.where{libelle == 'prices.large_family'}.update_all libelle: 'prices.promotion.large_family'
    Price.where{libelle == 'prices.couple'}.update_all libelle: 'prices.promotion.couple'
    Price.where{libelle == 'prices.training'}.update_all libelle: 'prices.promotion.training'
  end

  def down
    Price.where{libelle == 'prices.subscription.annual'}.update_all libelle: 'prices.annual'
    Price.where{libelle == 'prices.subscription.semester'}.update_all libelle: 'prices.semester'
    Price.where{libelle == 'prices.subscription.trimester'}.update_all libelle: 'prices.trimester'
    Price.where{libelle == 'prices.subscription.month'}.update_all libelle: 'prices.month'

    Price.where{libelle == 'prices.promotion.student'}.update_all libelle: 'prices.student'
    Price.where{libelle == 'prices.promotion.young_and_senior'}.update_all libelle: 'prices.young_and_senior'
    Price.where{libelle == 'prices.promotion.job_seeker'}.update_all libelle: 'prices.job_seeker'
    Price.where{libelle == 'prices.promotion.low_income'}.update_all libelle: 'prices.low_income'
    Price.where{libelle == 'prices.promotion.large_family'}.update_all libelle: 'prices.large_family'
    Price.where{libelle == 'prices.promotion.couple'}.update_all libelle: 'prices.couple'
    Price.where{libelle == 'prices.promotion.training'}.update_all libelle: 'prices.training'
  end
end
