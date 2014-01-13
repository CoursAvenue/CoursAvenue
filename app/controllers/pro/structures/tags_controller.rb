# encoding: utf-8
class Pro::Structures::TagsController < Pro::ProController
  before_action :load_structure

  def index
    @tags = @structure.owned_tags

    respond_to do |format|
      format.json { render json: @tags.to_json }
    end
  end

  private

  def load_structure
    @structure = Structure.friendly.find params[:structure_id]
  end
end
