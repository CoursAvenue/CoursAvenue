# encoding: utf-8
class Pro::ParticipationsController < Pro::ProController
  before_action :authenticate_pro_super_admin!
  layout 'admin'

  def index
    @participations       = Participation.all
    @participations_graph = {}
    Participation.where{created_at > Date.parse('04/01/2014')}.group_by{|p| p.created_at.to_date}.each do |date, participations|
      @participations_graph[date] = participations.length
    end
  end
end
