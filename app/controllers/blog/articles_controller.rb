# encoding: utf-8
class Blog::ArticlesController < ApplicationController

  layout 'blog'

  def index
    @articles   = Blog::Article::UserArticle.published.page(params[:page] || 1).per(5)
  end

  def tags
    @articles = Blog::Article::UserArticle.published.tagged_with(params[:tag]).page(params[:page] || 1).per(5)
  end

  def show
    @article           = Blog::Article::UserArticle.find params[:id]
    @article_decorator = BlogArticleDecorator.new(@article)
    unless current_pro_admin and current_pro_admin.super_admin?
      redirect_to blog_articles_path if ! @article.published?
    end
  end

  def category_index
    @category = Blog::Category::UserCategory.find params[:category_id]
    @articles = @category.articles.page(params[:page] || 1).per(5)
  end
end
