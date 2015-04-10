# encoding: utf-8
class Admin::Blog::Articles::MediasController < Pro::ProController
  before_action :authenticate_pro_super_admin!
  before_action :retrieve_article
  layout 'admin'

  def index
    @media  = @article.medias.build
    @medias = @article.medias.reject(&:new_record?)
  end

  def create
    params[:media_image][:url].split(',').each do |s3_filepicker_url|
      filepicker_url, s3_path = s3_filepicker_url.split(';')
      url                     = CoursAvenue::Application::S3_BUCKET.objects[s3_path].public_url.to_s
      Media::Image.create url: url, filepicker_url: filepicker_url, mediable: @article
    end
    respond_to do |format|
      format.html { redirect_to admin_blog_article_path(@article), notice: 'Vos images ont bien été ajoutées !' }
      format.js { render nothing: true }
    end
  end

  def update
    @image = @article.medias.find params[:id]
    @image.update_attributes params[:media]
    respond_to do |format|
      format.js { render nothing: true }
    end
  end

  def destroy
    @image = @article.medias.find params[:id]
    @image.destroy
    respond_to do |format|
      format.html { redirect_to edit_admin_blog_article_path(@article) }
      format.js { render nothing: true }
    end
  end

  def new
    @image = Media::Image.new mediable: @article
  end

  private

  def retrieve_article
    @article = Blog::Article::ProArticle.friendly.find params[:blog_article_id]
  end
end
