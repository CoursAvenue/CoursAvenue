class CreateCommunityThreads < ActiveRecord::Migration
  def change
    create_table :community_threads do |t|
      t.references :community, index: true
      t.boolean :public

      t.timestamps
    end
  end
end
