class AddAtStudentHomeToParticipationRequests < ActiveRecord::Migration
  def change
    add_column :participation_requests, :at_student_home, :boolean, default: false
    bar = ProgressBar.new ParticipationRequest.count
    ParticipationRequest.find_each do |pr|
      bar.increment!
      if pr.course.is_private? and pr.street.present? and pr.zip_code.present? and pr.city.present?
        pr.update_column :at_student_home, true
      end
    end
  end
end
