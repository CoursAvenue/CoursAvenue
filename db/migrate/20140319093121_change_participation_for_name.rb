class ChangeParticipationForName < ActiveRecord::Migration
  def change
    bar = ProgressBar.new Participation.count
    Participation.find_each do |participation|
      bar.increment!
      case participation.participation_for
      when 'participations.for.one_kid'
        participation.update_column :participation_for, 'participations.for.kids'
      when 'participations.for.one_kid_and_one_adult'
        participation.update_column :participation_for, 'participations.for.kids_and_adults'
      end
    end
  end
end
