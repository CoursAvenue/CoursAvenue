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

  def edit
    @tag = @structure.owned_tags.find params[:id]
    respond_to do |format|
      if request.xhr?
        format.html { render partial: 'form', layout: false }
      end
    end
  end

  private

  def load_structure
    @structure = Structure.friendly.find params[:structure_id]
  end
end
