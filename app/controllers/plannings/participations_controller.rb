# encoding: utf-8
class Plannings::ParticipationsController < ApplicationController
  helper :participations
  before_action :authenticate_user!
  before_action :load_planning

  def new
    @participation = @planning.participations.build
    respond_to do |format|
      if request.xhr?
        format.html { render partial: 'form' }
      end
    end
  end

  def create
    @participation = Participation.new planning: @planning, user: current_user
    respond_to do |format|
      if @participation.save
        format.html { redirect_to user_participations_path(current_user, inscription_confirmed: true), notice: 'Vous êtes bien inscrit à ce créneau' }
      else
        format.html { redirect_to jpo_structure_path(@planning.structure), notice: @participation.errors.messages[:base].to_sentence }
      end
    end
  end

  private

  def load_planning
    @planning      = Planning.find params[:planning_id]
  end
end
