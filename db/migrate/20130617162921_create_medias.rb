class CreateMedias < ActiveRecord::Migration
  def change
    create_table :medias do |t|
      t.string  :url
      t.text    :url_html
      t.string  :caption

      t.references :mediable, :polymorphic => true

      t.timestamps
    end
  end
end
