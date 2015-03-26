FactoryGirl.define do
  factory :blog_article, class: Blog::Article do
    factory :user_article, class: Blog::Article::UserArticle do
    end
  end
end
