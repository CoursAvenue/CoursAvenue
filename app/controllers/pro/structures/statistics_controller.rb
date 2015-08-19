# encoding: utf-8
class Pro::Structures::StatisticsController < Pro::ProController
  before_action :authenticate_pro_admin!
  load_and_authorize_resource :structure, find_by: :slug

  layout 'admin'

  def index
    @structure = Structure.friendly.find params[:structure_id]
    @client     = ::Analytic.client
    raw_data   = @client.hits(@structure.id)

    @empty_hash_of_days = {}
    (15.days.ago.to_date..Date.yesterday).each { |date| @empty_hash_of_days[date] = 0 }

    @website_planning_views, @views, @actions = (1..3).map { @empty_hash_of_days.dup }

    website_planning_page_view_data = @client.page_views(@structure.id, 'website/planning')
    website_planning_page_view_data.each do |entry|
      date = Date.parse(entry.date)
      @website_planning_views[date] = entry.pageviews.to_i
    end

    raw_data.each do |entry|
      date               = Date.parse(entry.date)

      @views[date]   = entry.metric2.to_i
      @actions[date] = @structure.participation_requests.where(created_at: (date.beginning_of_day..date.end_of_day)).count
      @actions[date] += @structure.mailbox.conversations.where(created_at: (date.beginning_of_day..date.end_of_day),
                                                      mailboxer_label_id: Mailboxer::Label::INFORMATION.id).count
      @actions[date] += @structure.user_favorites.where(structure_id: @structure.id, created_at: (date.beginning_of_day..date.end_of_day)).count
      @actions[date] += @client.action_count(@structure.id, 'phone_number')
      @actions[date] += @client.action_count(@structure.id, 'website')
    end

    @views_total_count            = @views.values.reduce(&:+)
    @actions_total_count          = @actions.values.reduce(&:+)
    @website_planning_views_count = @website_planning_views.values.reduce(&:+)
  end
end
