class AddIndexOnPhoneNumbersCallableIdAndType < ActiveRecord::Migration
  def change
    add_index :phone_numbers, [:callable_id, :callable_type]
  end
end
