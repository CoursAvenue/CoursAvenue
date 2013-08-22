class FixPricesToNewStructure < ActiveRecord::Migration
  def up
    bar = ProgressBar.new (Price.count + BookTicket.count + RegistrationFee.count)
    ::BookTicket.where{amount != nil}.each do |book_ticket|
      bar.increment!
      price = ::Price.new(type: 'Price::BookTicket', number: book_ticket.number, amount: book_ticket.amount, promo_amount: book_ticket.promo_amount)
      price.course = book_ticket.course
      price.save
    end
    ::BookTicket.delete_all
    RegistrationFee.all.each do |fee|
      bar.increment!
      price = Price::Registration.new amount: fee.amount, info: fee.info
      price.course = fee.course
      price.save
    end
    RegistrationFee.delete_all

    Price.where{libelle == 'prices.trial_lesson' }.each do |price|
      bar.increment!
      price.update_column :type, 'Price::Discount'
      price.update_column :libelle, 'prices.discount.trial_lesson'
    end
    Price.where{libelle == 'prices.two_lesson_per_week_package' }.each do |price|
      bar.increment!
      price.update_column :type, 'Price::Subscription'
      price.update_column :libelle, 'prices.subscription.annual'
    end
    Price.where{libelle =~ '%promotion%' }.each do |price|
      bar.increment!
      price.update_column :libelle, price.libelle.gsub('promotion', 'discount')
      price.update_column :type, 'Price::Discount'
    end
    Price.where{libelle == 'prices.individual_course'}.each do |price|
      bar.increment!
      price.update_column :type, 'Price::BookTicket'
      price.update_column :libelle, nil
      price.update_column :number, 1
    end
    Price.where{libelle =~ '%subscription%'}.each do |price|
      bar.increment!
      price.update_column :type, 'Price::Subscription'
    end
  end

  def down
  end
end
