# encoding: utf-8
class ParticipationMailer < ActionMailer::Base
  helper :plannings, :levels

  layout 'email'

  default from: "\"L'équipe de CoursAvenue.com\" <contact@coursavenue.com>"

  def alert_for_destroy(participation)
    @user     = participation.user
    @planning = participation.planning
    @course   = participation.course
    # mail to: @user.email, subject: 'Destroy'
  end

  def alert_for_changes(participation)
    @user     = participation.user
    @planning = participation.planning
    @course   = participation.course
    # mail to: @user.email, subject: 'Change'
  end
end
