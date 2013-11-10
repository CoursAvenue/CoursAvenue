# encoding: utf-8
class Pro::Structures::StickerDemandsController < Pro::ProController
  before_action               :authenticate_pro_admin!
  load_and_authorize_resource :structure, find_by: :slug

  def create
    @structure      = Structure.friendly.find params[:structure_id]
    @sticker_demand = @structure.sticker_demands.build params[:sticker_demand]
    respond_to do |format|
      if @sticker_demand.save
        format.html { redirect_to pro_structure_sticker_demands_path(@structure), notice: 'Votre demande à bien été transmise'}
      else
        format.html { render action: 'new' }
      end
    end
  end

  def new
    @sticker_demand = @structure.sticker_demands.build
  end
end
