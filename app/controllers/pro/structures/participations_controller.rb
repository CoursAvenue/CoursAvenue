# encoding: utf-8
class Pro::Structures::ParticipationsController < Pro::ProController
  before_action :authenticate_pro_admin!
  before_action :load_structure

  layout 'admin'

  load_and_authorize_resource :structure

  def index
    @open_courses = @structure.courses.open_courses
  end

  def pop_from_waiting_list
    participation = @structure.participations.find params[:id]
    respond_to do |format|
      if participation.pop_from_waiting_list
        format.html { redirect_to pro_structure_participations_path(@structure), notice: "L'inscription est passé en accepté" }
      else
        format.html { redirect_to pro_structure_participations_path(@structure), error: "Une erreur s'est produite. Veuillez réessayer. " }
      end
    end
  end

  private

  def load_structure
    @structure = Structure.friendly.find(params[:structure_id])
  end
end
