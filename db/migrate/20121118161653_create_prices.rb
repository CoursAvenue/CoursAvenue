class CreatePrices < ActiveRecord::Migration
  def change
    create_table :prices do |t|
      t.string     :libelle
      t.decimal    :amount
      t.references :course_group
      t.timestamps
    end
  end
end
