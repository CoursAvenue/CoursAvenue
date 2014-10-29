class CreateFaqSections < ActiveRecord::Migration
  def change
    create_table :faq_sections do |t|
      t.string :title
    end
  end
end
