namespace :datatool do
  require 'yaml'
  require 'json'

  def save_summaries_to_file(summaries, filename)
    output = File.open( filename, "w" )
    output << summaries
    output.close
  end

  # This task is used to backup data from fedora/hyrax to json file
  # To backup:
  # In the server you want to backup, under OASIS folder, run:
  # RAILS_ENV=production/development bundle exec rake datatool:backup[json_file_name]
  # e.g. RAILS_ENV=production bundle exec rake datatool:backup[/var/tmp/oasis_data.json]
  desc "Backup data ..."
  task :backup, [:json_file_name] => [:environment] do |t, args|
    target_file_name = args[:json_file_name]
    summaries = '['

    Summary.find_each do |s|
      unless s.nil?
        puts "Processing " + s.id
        summaries = summaries + s.to_json + ","
      end
    end
    summaries = summaries.chomp(',') if summaries.end_with? ','
    summaries = summaries + ']'

    save_summaries_to_file(summaries, target_file_name)
    puts "Done."
  end

  # This task is used to restore data to fedora/hyrax
  # To restore:
  # RAILS_ENV=production/development bundle exec rake datatool:restore[json_file_name]
  # e.g. RAILS_ENV=production bundle exec rake datatool:restore[/var/tmp/oasis_data.json]
  desc "Restore data ..."
  task :restore, [:json_file_name] => [:environment] do |t, args|
    source_file_name = args[:json_file_name]
    file = File.read(source_file_name)
    data_hash = JSON.parse(file)

    data_hash.each do |s|
      puts "restoring " + s["id"]
      new_summary = Summary.new
      

      break
    end

    puts "Done."
  end
end