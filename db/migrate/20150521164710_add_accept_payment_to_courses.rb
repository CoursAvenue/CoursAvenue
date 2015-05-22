class AddAcceptPaymentToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :accepts_payment, :boolean
  end
end
