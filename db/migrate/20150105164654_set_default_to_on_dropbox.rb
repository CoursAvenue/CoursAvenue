class SetDefaultToOnDropbox < ActiveRecord::Migration
  def up
    Order.all.each do |order|
      order.update_attribute(:on_dropbox, false)
    end
  end

  def down
    Order.all.each do |order|
      order.update_attribute(:on_dropbox, nil)
    end
  end
end
