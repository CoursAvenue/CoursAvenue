require 'rails_helper'

describe Pro::Blog::ArticlesController do
  describe '#show' do

    context 'when it is a pro article' do
      let(:article) { Blog::Article::ProArticle.create }
      it 'renders the show view' do
        get :show, id: article.slug
        expect(response).to have_http_status(:success)
      end
    end

    context 'when it is a user article' do
      let(:article) { Blog::Article::UserArticle.create }

      it 'redirects to the user article blog' do
        get :show, id: article.id
        expect(response).to redirect_to(blog_article_path(article, subdomain: 'www'))
      end
    end
  end
end
