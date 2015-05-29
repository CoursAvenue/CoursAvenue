namespace :places do

  # Use rake places:affect_subjects
  desc 'Generate the invoices of existing orders'
  task :affect_subjects => :environment do
    bar = ProgressBar.new Place.count
    Place.find_each do |place|
      place.delay.affect_subjects
      bar.increment!
    end
  end
end
