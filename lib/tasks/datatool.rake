namespace :datatool do
  require 'yaml'
  require 'json'
  require 'time'

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
    existing_summaries = []

    # Processing each Summary from JSON
    data_hash.each do |s|
      id = s["id"]
      begin
        Summary.find(id)
        # If found
        existing_summaries << id
        #puts '>>Already exist: ' + id
        next
      rescue
        # Not found, then create a new Summary as below
      end

      puts "restoring " + id
      new_summary = Summary.new  #.from_json(s.to_json)
      new_summary.attribute_names.each do |name|
        unless s[name].nil? or s[name]=='' or name=='state'   # or (s[name].class==Array and s[name].length==0)
          #puts "restoring: #{name} >> [#{s[name].class}]: #{s[name]}" unless s[name].nil? or s[name]==''
          if name.start_with? 'date'
            if s[name].class!=Array
              new_summary.send("#{name}=",Time.parse(s[name]))
            end
          else
            new_summary.send("#{name}=",s[name])
          end
        end
      end
      new_summary.id    = id
      new_summary.state = ActiveTriples::Resource.new(s['state']['id']) unless s['state'].nil? or s['state']['id'].nil?
      new_summary.save
    end

    puts "Done."

    if existing_summaries.length>0
      puts 'Existing summaries'
      puts '============================'
      existing_summaries.each do |s|
        puts s
      end
    end
  end
end