class Structures::CommunityController < ApplicationController
  before_filter :set_structure

  def show
    @community = @structure.community

    respond_to do |format|
      format.html { redirect_to structure_path(@structure) }
      format.json { render json: @community }
    end
  end

  private

  def set_structure
    @structure = Structure.includes(:community).friendly.find(params[:structure_id])
  end
end
