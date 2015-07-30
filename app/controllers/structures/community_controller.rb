class Structures::CommunityController < ApplicationController
  def show
    @structure = Structure.includes(:community).friendly.find(params[:structure_id])
    @community = @structure.community

    respond_to do |format|
      format.html { redirect_to structure_path(@structure) }
      format.json { render json: @community }
    end
  end
end
