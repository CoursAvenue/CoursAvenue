# encoding: utf-8
class Plannings::ParticipationsController < ApplicationController
  helper :participations
  before_action :authenticate_user!
  before_action :load_planning

  def new
    @participation = @planning.participations.build
    respond_to do |format|
      if request.xhr?
        if current_user.can_participate_to_jpo_2014?
          format.html { render partial: 'form' }
        else
          format.html { render partial: 'cannot_participate' }
        end
      end
      format.html { redirect_to jpo_structure_path(@planning.structure)}
    end
  end

  def create
    @participation      = @planning.participations.build params[:participation]
    @participation.user = current_user
    respond_to do |format|
      if @participation.save
        format.js
        format.html { redirect_to user_participations_path(current_user, inscription_confirmed: true), notice: 'Vous êtes bien inscrit à ce créneau' }
      else
        format.js
        format.html { redirect_to jpo_structure_path(@planning.structure), alert: @participation.errors.messages[:base].to_sentence }
      end
    end
  end

  private

  def load_planning
    @planning = Planning.find params[:planning_id]
  end
end
