# encoding: utf-8
class Pro::SubjectsController < Pro::ProController
  include SubjectSeeker

  before_action :authenticate_pro_super_admin!, except: :descendants

  def index
    @roots    = Subject.roots.order('name ASC').all
    @parents  = Subject.at_depth(1).order('name ASC').all
    @children = Subject.at_depth(2).order('name ASC').all
    @subjects = @roots + @parents + @children
  end

  def new
    @parent  = Subject.fetch_by_id_or_slug params[:parent_id]
    @subject = @parent.children.build
    respond_to do |format|
      format.html { render layout: false }
    end
  end

  def create
    @subject = Subject.create params[:subject]
    Rails.cache.delete "Pro::SubjectsController#descendants::#{@subject.parent.try(:id)}"
    Rails.cache.delete "Pro::SubjectsController#descendants::#{@subject.root.id}"
    respond_to do |format|
      format.html { redirect_to pro_subjects_path }
    end
  end

  def edit
    @subject    = Subject.friendly.find params[:id]
    respond_to do |format|
      format.html { render layout: false }
    end
  end

  def update
    @subject = Subject.friendly.find params[:id]
    respond_to do |format|
      if @subject.update_attributes params[:subject]
        format.js { render nothing: true }
        format.html { redirect_to pro_subjects_path }
      else
        format.html { render action: :edit }
      end
    end
  end

  # Params:
  #    ids: subject ids separeted by comas (123,124,53)
  #  Returns json:
  #     Danse - Danse de salon :
  #           - Salsa
  #           - Zumba
  #           - ...
  #     Cuisine - ...:
  #           - ...
  def descendants
    @descendants = Rails.cache.fetch "Pro::SubjectsController#descendants::#{params[:ids]}" do
       get_descendants(params).to_json
    end
    respond_to do |format|
      if params[:callback]
        format.js { render json: { descendants: @descendants }, callback: params[:callback] }
      else
        format.json { render json: @descendants }
      end
    end
  end
end
