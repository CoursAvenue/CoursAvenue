# encoding: utf-8
class Pro::SubjectsController < Pro::ProController

  before_action :authenticate_pro_super_admin!, except: :descendants

  def index
    @city = City.find 'paris'
    @structure_search = StructureSearch.search({lat: @city.latitude, lng: @city.longitude, radius: 7, per_page: 1, bbox: true})
  end

  def edit
    @subject = Subject.friendly.find params[:id]
  end

  def update
    @subject = Subject.friendly.find params[:id]
    respond_to do |format|
      if @subject.update_attributes params[:subject]
        format.html { redirect_to pro_subjects_path}
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
    @subjects = params[:ids].split(',').map{ |id| Subject.friendly.find(id) }
    @descendants = []
    @subjects.each do |parent_subject|
      parent_subject.descendants.at_depth(1).each do |first_descendant|
        obj                = {}
        parent_name        = first_descendant.name
        obj[parent_name] ||= []
        first_descendant.children.order('name ASC').each do |second_descendant|
          obj[parent_name] << second_descendant
        end
        @descendants << obj
      end
    end
    @descendants = @descendants.sort_by{|subj| subj.keys[0]}
    respond_to do |format|
      if params[:callback]
        format.js { render :json => {descendants: @descendants.to_json}, callback: params[:callback] }
      else
        format.json { render json: @descendants.to_json }
      end
    end
  end
end
