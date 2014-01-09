# encoding: utf-8
class Plannings::ParticipationsController < Pro::ProController

  def create
    @planning      = Planning.find params[:planning_id]
    @participation = Participations.new planning: @planning, user: current_user
    respond_to do |format|
      if @participation.save
        format.html
      else
        format.html
      end
    end
  end

end
