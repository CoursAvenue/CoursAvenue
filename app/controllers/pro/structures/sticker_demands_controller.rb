# encoding: utf-8
class Pro::Structures::StickerDemandsController < Pro::ProController
  before_action               :authenticate_pro_super_admin!, only: [:sent]
  load_and_authorize_resource :structure, find_by: :slug

  def create
    @structure      = Structure.friendly.find params[:structure_id]
    @sticker_demand = @structure.sticker_demands.build params[:sticker_demand]
    respond_to do |format|
      if @sticker_demand.save
        AdminMailer.delay(queue: 'mailers').stickers_has_been_ordered(@sticker_demand)
        SuperAdminMailer.delay(queue: 'mailers').inform_admin('Des stickers ont été commandés', "Des sticker ont été commandés par #{@structure.name} : #{@sticker_demand.round_number} ronds et #{@sticker_demand.square_number} rectangulaires")
        format.html { redirect_to communication_pro_structure_path(@structure), notice: 'Votre demande a bien été transmise' }
      else
        format.html { render template: 'pro/structures/communication' }
      end
    end
  end

  def new
    @sticker_demand = @structure.sticker_demands.build
  end

  def update_sent
    @sticker_demand      = StickerDemand.find params[:id]
    @sticker_demand.send!
    AdminMailer.delay(queue: 'mailers').stickers_has_been_sent(@sticker_demand)
    redirect_to pro_sticker_demands_path
  end
end
