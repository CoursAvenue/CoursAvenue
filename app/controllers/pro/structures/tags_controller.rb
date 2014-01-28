# encoding: utf-8
class Pro::Structures::TagsController < Pro::ProController
  before_action :load_structure

  def index
    @tags = @structure.owned_tags

    respond_to do |format|
      format.html
      format.json { render json: @tags.to_json }
    end
  end

  def new
    @tag = @structure.owned_tags.build
    respond_to do |format|
      if request.xhr?
        format.html { render partial: 'form', layout: false }
      end
    end
  end

  def create
    respond_to do |format|
      if @structure.create_tag(params[:tag][:name])
        format.html { redirect_to pro_structure_tags_path(@structure), notice: 'Le tag a bien été créé' }
      else
        format.html { redirect_to pro_structure_tags_path(@structure), alert: "Le tag existe déjà" }
      end
    end
  end

  def edit
    @tag = @structure.owned_tags.find params[:id]
    respond_to do |format|
      if request.xhr?
        format.html { render partial: 'form', layout: false }
      end
    end
  end

  def update
    @tag = @structure.owned_tags.find params[:id]

    respond_to do |format|
      if @tag.update_attributes params[:tag]
        format.html { redirect_to pro_structure_tags_path(@structure), notice: 'Le tag a bien été mis à jour' }
      else
        format.html { redirect_to pro_structure_tags_path(@structure), alert: "Une erreur est survenue, le tag n'a pu être mis à jour." }
      end
    end
  end

  def destroy
    @tag = @structure.owned_tags.find params[:id]

    respond_to do |format|
      if @tag.destroy
        format.html { redirect_to pro_structure_tags_path(@structure), notice: 'Le tag a bien été mis à jour' }
      else
        format.html { redirect_to pro_structure_tags_path(@structure), alert: "Une erreur est survenue, le tag n'a pu être mis à jour." }
      end
    end
  end

  private

  def load_structure
    @structure = Structure.friendly.find params[:structure_id]
  end
end
