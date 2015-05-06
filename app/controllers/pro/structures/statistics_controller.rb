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

    if @structure.premium?
      gather_premium_stats
    end

    @impressions, @views, @actions = (1..3).map { @empty_hash_of_days.dup }

    raw_data.each do |entry|
      date               = Date.parse(entry.date)

      @impressions[date] = entry.metric1.to_i
      @views[date]       = entry.metric2.to_i
      @actions[date] = ParticipationRequest.where(created_at: (date.beginning_of_day..date.end_of_day), from_personal_website: false).count
      @actions[date] += Mailboxer::Conversation.where(created_at: (date.beginning_of_day..date.end_of_day),
                                                      mailboxer_label_id: Mailboxer::Label::INFORMATION.id).count
      @actions[date] += Following.where(structure_id: @structure.id, created_at: (date.beginning_of_day..date.end_of_day)).count
    end

    @impressions_total_count = @impressions.values.reduce(&:+)
    @views_total_count       = @views.values.reduce(&:+)
    @actions_total_count     = @actions.values.reduce(&:+)
  end

  private

  def gather_premium_stats
    @website_views, @website_planning_views, @website_inscription = (1..3).map { @empty_hash_of_days.dup }

    website_planning_page_view_data = @client.page_views(@structure.id, 'website/planning')
    website_planning_page_view_data.each do |entry|
      date = Date.parse(entry.date)
      @website_planning_views[date] = entry.pageviews.to_i
    end

    if @structure.subscription.plan.website_plan?
      website_page_view_data = @client.page_views(@structure.id, 'website')
      website_page_view_data.each do |entry|
        date = Date.parse(entry.date)
        @website_views[date] = entry.pageviews.to_i
      end
    end

    (15.days.ago.to_date..Date.yesterday).each do |date|
      @website_inscription[date] = ParticipationRequest.where(created_at: (date.beginning_of_day..date.end_of_day), from_personal_website: false).count
    end
    @website_views_total_count        = @website_views.values.reduce(&:+)
    @website_planning_views_count     = @website_planning_views.values.reduce(&:+)
    @website_inscriptions_total_count = @website_inscription.values.reduce(&:+)
  end
end
