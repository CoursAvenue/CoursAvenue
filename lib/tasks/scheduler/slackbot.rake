# encoding: utf-8
require 'rake/clean'

namespace :scheduler do
  namespace :slackbot do

    # Sends a message every monday morning to tell number of partcipation requests
    # $ rake scheduler:slackbot:presents_requests_metrics
    desc 'Send email to admins who have user requests not answered'
    task :presents_requests_metrics => :environment do |t, args|
      return if !Date.today.monday?
      pr_count        = ParticipationRequest.where(created_at:(7.days.ago..Date.tomorrow)).count
      past_pr_count   = ParticipationRequest.where(created_at:(14.days.ago..7.days.ago)).count
      pr_count_growth = ((pr_count.to_f - past_pr_count.to_f) / past_pr_count.to_f) * 100
      pr_count_growth = 0 if pr_count_growth == Float::INFINITY
      pr_ca_count      = ParticipationRequest.from_personal_ca.where(created_at:(7.days.ago..Date.tomorrow)).count
      pr_website_count = ParticipationRequest.from_personal_website.where(created_at:(7.days.ago..Date.tomorrow)).count

      uri = URI("https://hooks.slack.com/services/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")
      text = "Bonjour à tous !\n"
      text += "Il y a eu cette semaine #{pr_count} inscriptions, voici le détail :\n"
      text += ":chart_with_upwards_trend: Croissance : #{pr_count_growth.to_i}%\n"
      text += "Depuis CoursAvenue : #{pr_ca_count}\n"
      text += "Depuis la page planning des profs : #{pr_website_count}\n"
      text += "<https://pro.coursavenue.com/participation_requests|Voir le détail des inscriptions>\n"
      text += "<https://www.google.com/analytics/web/?hl=en#report/content-drilldown/a36532956w65949456p67806356/%3F_u.date00%3D20150618%26_u.date01%3D20150618%26explorer-table.plotKeys%3D%5B%5D%26explorer-table.rowStart%3D0%26explorer-table.rowCount%3D250%26_r.drilldown%3Danalytics.pagePathLevel1%3Awww.coursavenue.com%2F%2Canalytics.pagePathLevel2%3A%2Freservation%2F/|Voir le trafic des pages plannings sur GoogleAnalytics>\n"
      message = {
        "username": "Metric Buddy",
        "icon_emoji": ":rocket:",
        "channel": "#metrics",

        "text": text
      }.to_json
      Net::HTTP.post_form(uri, { payload: message })
    end
  end
end
