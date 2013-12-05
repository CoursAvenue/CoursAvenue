# encoding: utf-8
class Pro::KeywordsController < Pro::ProController
  layout 'admin'
  before_action :authenticate_pro_super_admin!

  def index
    @keywords = Keyword.all
    @keyword  = Keyword.new
  end

  def create
    @keyword = Keyword.create params[:keyword]
    respond_to do |format|
      if @keyword.save
        format.html { redirect_to pro_keywords_path }
      else
        format.html { redirect_to pro_keywords_path, error: 'Il y a eu un problème, le mot clé existe peut-être déjà' }
      end
    end
  end

  def destroy
    @keyword = Keyword.find params[:id]
    respond_to do |format|
      if @keyword.destroy
        format.html { redirect_to pro_keywords_path }
      else
        format.html { redirect_to pro_keywords_path, error: 'Il y a eu un problème' }
      end
    end
  end
end
