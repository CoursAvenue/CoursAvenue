class AddNbKidsAndNbAdultsToParticipations < ActiveRecord::Migration
  def up
    add_column :participations, :nb_adults, :integer, default: 1
    add_column :participations, :nb_kids, :integer, default: 0

    bar = ProgressBar.new Participation.count
    Participation.find_each do |participation|
      bar.increment!
      participation.nb_adults = 1
      participation.nb_kids   = (participation.with_kid? ? 1 : 0)
      participation.save(validate: false)
    end
  end

  def down
    remove_column :participations, :nb_adults
    remove_column :participations, :nb_kids
  end
end
