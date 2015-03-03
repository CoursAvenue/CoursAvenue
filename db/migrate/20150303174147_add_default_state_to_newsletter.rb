class AddDefaultStateToNewsletter < ActiveRecord::Migration
  def change
    change_column_default :newsletters, :state, 'draft'
  end
end
