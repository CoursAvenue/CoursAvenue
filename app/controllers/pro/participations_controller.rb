# encoding: utf-8
class Pro::ParticipationsController < Pro::ProController
  before_action :authenticate_pro_super_admin!
  layout 'admin'

  def index
    @participations       = Participation.order('canceled_at DESC, created_at DESC').all
    @participations_graph, @canceled_participations_graph = {}, {}
    dates = (Date.parse('2014/03/03')..Date.today).step
    dates.each do |date|
      @participations_graph[date]          = 0
      @canceled_participations_graph[date] = 0
    end
    @participations_per_hour = { 0 => 0, 1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0, 6 => 0, 7 => 0, 8 => 0, 9 => 0, 10 => 0, 11 => 0, 12 => 0, 13 => 0, 14 => 0, 15 => 0, 16 => 0, 17 => 0, 18 => 0, 19 => 0, 20 => 0, 21 => 0, 22 => 0, 23 => 0 }
    Participation.find_each do |participation|
      @participations_per_hour[participation.created_at.hour] += 1
    end
    Participation.not_canceled.where{created_at > Date.parse('2014/03/03')}.group_by{|p| p.created_at.to_date}.each do |date, participations|
      @participations_graph[date] = participations.length
    end
    Participation.canceled.where{created_at > Date.parse('2014/03/03')}.group_by{|p| p.created_at.to_date}.each do |date, participations|
      @canceled_participations_graph[date] = participations.length
    end
  end
end
