class CreateInvitedTeachers < ActiveRecord::Migration
  def change
    create_table :invited_teachers do |t|
      t.string   'email', null: false
      t.references :structure

      t.timestamps
    end
  end
end
