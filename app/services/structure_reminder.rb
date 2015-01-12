class StructureReminder
  # Send a reminder depending on the email status of the structure.
  # @param structure The Structure to send the reminder to
  #
  # @return nil
  def self.status(structure)
    return if structure.main_contact.nil? or structure.is_sleeping?

    if structure.main_contact.monday_email_opt_in? and structure.update_email_status.present?
      status = structure.email_status
      structure.update_last_email_sent_status!(status)
      AdminMailer.delay.send(status.to_sym, structure)
    end
  end

  # Send a reminder when there are pending comments on the structure.
  # @param structure The Structure to send the reminder to
  #
  # @return nil
  def self.pending_comments(structure)
    return if structure.comments.pending.empty?
    AdminMailer.delay.remind_for_pending_comments(structure)
  end

  # Send a reminder for widget availability.
  # @param structure The Structure to send the reminder to
  #
  # @return nil
  def self.widget(structure)
    if structure.main_contact and structure.main_contact.monday_email_opt_in?
      if structure.widget_status.nil?
        AdminMailer.delay.remind_for_widget(structure)
      end
    end
  end

  # Send a reminder when there's an outdated course
  # @param structure The Structure to send the reminder to
  #
  # @return nil
  def self.outdated_planning(structure)
    return if structure.courses.without_open_courses.detect(&:is_published?)

    if structure.main_contact and structure.main_contact.monday_email_opt_in?
      AdminMailer.delay.planning_outdated(structure)
    end
  end
end
