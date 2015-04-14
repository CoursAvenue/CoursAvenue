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
    (15.days.ago.to_date..Date.yesterday).each { |date| @empty_hash_of_days[date] = 0 }

    @impressions, @views, @actions = (1..3).map { @empty_hash_of_days.dup }
    @impressions_total_count, @views_total_count, @actions_total_count = 0, 0, 0

    raw_data.each do |entry|
      date               = Date.parse(entry.date)

      @impressions[date] = entry.metric1.to_i
      @views[date]       = entry.metric2.to_i
      @actions[date]     = entry.metric3.to_i
    end

    @impressions_total_count = @impressions.values.reduce(&:+)
    @views_total_count       = @views.values.reduce(&:+)
    @actions_total_count     = @actions.values.reduce(&:+)
  end
end
