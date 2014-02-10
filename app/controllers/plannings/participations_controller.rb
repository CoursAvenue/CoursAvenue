# encoding: utf-8
class Plannings::ParticipationsController < Pro::ProController
  before_action :authenticate_user!

  def new
    if request.xhr?
      format.html { render partial: 'form' }
    end
  end

  def create
    @planning      = Planning.find params[:planning_id]
    @participation = Participation.new planning: @planning, user: current_user
    respond_to do |format|
      if @participation.save
        format.html { redirect_to user_participations_path(current_user), notice: 'Vous êtes bien inscrit à ce créneau' }
      else
        format.html
      end
    end
  end

  def destroy
    @planning      = Planning.find params[:planning_id]
    @participation = @planning.participations.find params[:id]
    respond_to do |format|
      if @participation.destroy
        format.html { redirect_to user_participations_path(current_user), notice: 'Vous êtes bien désinscrit à ce créneau' }
      else
        format.html
      end
    end
  end
end
