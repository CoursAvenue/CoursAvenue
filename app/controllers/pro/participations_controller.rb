# encoding: utf-8
class Pro::ParticipationsController < Pro::ProController
  before_action :authenticate_pro_super_admin!
  layout 'admin'

  def index
    @participations       = Participation.all
    @participations_graph = {}
    dates = (Date.parse('2014/03/03')..Date.today).step
    dates.each do |date|
      @participations_graph[date] = 0
    end
    Participation.where{created_at > Date.parse('2014/03/03')}.group_by{|p| p.created_at.to_date}.each do |date, participations|
      @participations_graph[date] = participations.length
    end
  end
end
