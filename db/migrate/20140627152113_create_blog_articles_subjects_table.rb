class CreateBlogArticlesSubjectsTable < ActiveRecord::Migration
  def change
    create_table :blog_articles_subjects do |t|
      t.references :article, :subject
    end
    add_index :blog_articles_subjects, [:article_id, :subject_id]
  end
end
