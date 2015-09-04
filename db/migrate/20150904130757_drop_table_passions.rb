class DropTablePassions < ActiveRecord::Migration
  def change
    bar = ProgressBar.new(Passion.count)
    Passion.find_each do |passion|
      bar.increment!
      next if passion.user.nil?
      user = passion.user
      user.subjects = passion.subjects
      user.subjects = user.subjects.uniq
      user.save
    end
    drop_table :passions
    drop_table :passions_subjects
  end
end
