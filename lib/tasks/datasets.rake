namespace :datasets do

  # refresh datasets with pure data from the last x days
  task :refresh, [:days] => :environment do |t, args|
    refreshed = DepositsController.new.refresh_from_pure(nil, args[:days])
    puts '========= ' + DateTime.now.to_s + ' ========'
    puts 'Refreshed ' + refreshed.size.to_s + ' record(s)'
    puts refreshed
  end
end
