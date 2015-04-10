# encoding: utf-8
class Pro::Structures::StatisticsController < Pro::ProController
  before_action :authenticate_pro_admin!
  load_and_authorize_resource :structure, find_by: :slug

  layout 'admin'

  def index
    @structure = Structure.find params[:structure_id]
    client     = ::Analytic.client
    raw_data   = client.hits(@structure.id)

    @empty_hash_of_days = {}
    (15.days.ago.to_date..Date.today).each { |date| @empty_hash_of_days[date] = 0 }

    @impressions, @views, @follow_actions = (1..3).map { @empty_hash_of_days.dup }
    @impressions_total_count, @views_total_count, @actions_total_count = 0, 0, 0

    @impressions = raw_data.map do |entry|
      entry.metric1.to_i
    end

    @views       = raw_data.map do |entry|
      entry.metric2.to_i
    end

    @actions = raw_data.map do |entry|
      entry.metric3.to_i
    end

    @impressions_total_count = @impressions.reduce(&:+)
    @views_total_count       = @views.reduce(&:+)
    @actions_total_count     = @actions.reduce(&:+)
  end
end
