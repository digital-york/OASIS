namespace :authorities do
  require 'yaml'
  require 'figaro'

  SOLR = Figaro.env.solr_url

  # save term array into a file
  def save_terms_to_file(terms, filename)
    output = File.open( filename, "w" )
    output << "terms:\n"
    other_term = nil
    terms.each do |t|
      # always add 'Other' to the end of the term list
      if t["term"].downcase != 'other'
        output << "  - id: " + t["id"].to_s + "\n"
        output << "    term: \"" + t["term"] +"\"\n"
      else
        other_term = t
      end
    end
    unless other_term.nil?
      output << "  - id: "    + other_term["id"].to_s + "\n"
      output << "    term: \""+ other_term["term"] +"\"\n"
    end
    output.close
  end

  # Check if a term is referenced by any object before being deleted
  def is_term_used(authority_file_name, term)
    solr_field = OasisAuthorityMapping.authority_mapping_filename2solr[authority_file_name.sub('.yml','')]
    solr = RSolr.connect :url => SOLR
    response = solr.get 'select', :params => {
        :q=>"#{solr_field}_label_tesim:\"#{term}\"",
        :start=>0,
        :rows=>10
    }
    return false if response["response"]["numFound"] == 0
    true
  end

  # update a term in solr
  def update_solr(authority_file_name, old_term, new_term)
    solr_field = OasisAuthorityMapping.authority_mapping_filename2solr[authority_file_name.sub('.yml','')]
    solr = RSolr.connect :url => SOLR

    solr_field = OasisAuthorityMapping.authority_mapping_filename2solr[authority_file_name.sub('.yml','')]
    solr = RSolr.connect :url => SOLR

    # find the object first
    response = solr.get 'select', :params => {
        :q=>"#{solr_field}_label_tesim:\"#{old_term}\"",
        :start=>0,
        :rows=>10
    }
    return false if response["response"]["numFound"] == 0
    doc_id = response["response"]["docs"]["id"]

    # update solr_index
    solr.update :data => "id:#{doc_id}, #{solr_field}_label_tesim:\"#{new_term}\"", headers: { 'Content-Type' => 'application/json' }
    true
  end

  # To run this task, type:
  # rake authorities:create_yaml[/var/tmp/x.csv,/var/tmp/target.yml]
  desc "Generating authorities YAML texts from CSV..."
  task :create_yaml, [:sourcefile,:targetfile] => [:environment] do |t, args|
    terms = []
    File.foreach(args[:sourcefile]).with_index do |line, line_num|
      terms << {"id"=>line_num+1, "term"=>line.squish}
    end
    save_terms_to_file(terms, args[:targetfile])
  end

  # To run this task, run:
  # bundle exec rake authorities:add_terms[AUTHORITY_YAML_FILE,NEW_TERMS_CSV,UPDATED_YAML_FILE]
  # e.g.
  # bundle exec rake authorities:add_terms[config/authorities/journals.yml,lib/assets/authorities/add/20180807_journals.csv,config/authorities/journals_new.yml]
  # be careful with the special characters in the CSV file, especially in the first line!
  desc "Adding authorities YAML file from CSV..."
  task :add_terms, [:yamlfile, :csvfile, :targetfile] => [:environment] do |t, args|
    yaml = YAML.load_file(args[:yamlfile])
    terms = yaml['terms']
    max_id = 0
    terms.each do |t|
      max_id = t['id'].to_i if t['id'].to_i>max_id  # and t['term'].downcase!='other'
    end

    File.foreach(args[:csvfile]).with_index do |line, line_num|
      newid    = max_id+line_num+1
      newlabel = line.squish
      if newlabel.strip! !=''
        terms << {"id"=>newid, "term"=>newlabel}
      end
    end
    sorted_terms = terms.sort_by {|k| k["term"]}
    save_terms_to_file(sorted_terms, args[:targetfile])
  end


  # To run this task, run:
  # bundle exec rake authorities:del_terms[AUTHORITY_YAML_FILE,NEW_TERMS_CSV,UPDATED_YAML_FILE]
  # e.g.
  # bundle exec rake authorities:del_terms[config/authorities/journals.yml,lib/assets/authorities/delete/20180807_journals.csv,config/authorities/journals_new.yml]
  desc "Deleting authorities terms from CSV..."
  task :del_terms, [:yamlfile,:csvfile,:targetfile] => [:environment] do |t, args|
    yaml = YAML.load_file(args[:yamlfile])
    terms = yaml['terms']

    File.foreach(args[:csvfile]) do |line|
      if is_term_used(args[:yamlfile], line.squish)==false
        terms.delete_if {|t| t['term']==line.squish}
      else
        puts "found #{line.squish}, bypass this term"
      end
    end
    save_terms_to_file(terms, args[:targetfile])
  end

  # To run this task, run:
  # bundle exec rake authorities:update_terms[AUTHORITY_YAML_FILE,NEW_TERMS_CSV,UPDATED_YAML_FILE]
  # e.g.
  # bundle exec rake authorities:update_terms[config/authorities/research_areas.yml,lib/assets/authorities/update/20180808_topics.csv,config/authorities/topics_new.yml]
  desc "Updating authorities from CSV..."
  task :update_terms, [:yamlfile,:csvfile,:targetfile] => [:environment] do |t, args|
    yaml = YAML.load_file(args[:yamlfile])
    terms = yaml['terms']

    #puts terms.class

    File.foreach(args[:csvfile]) do |line|
      old_term = line.squish.split(',,,')[0]
      new_term = line.squish.split(',,,')[1]

      # update the authorities file first
      terms.collect! { |t|
        if t['term'] == old_term
          t['term'] == new_term
          t
        else
          t
        end
      }

      # if the term is used, update solr as well
      if is_term_used(args[:yamlfile], line.squish)==true
        puts 'updating solr...'
        update_solr(args[:yamlfile], old_term, new_term)
      end

    end
    #save_terms_to_file(terms, args[:targetfile])
  end


  # To run this task, type:
  # bundle exec rake authorities:create_yaml[FILE_NAME]
  desc "Generating authorities YAML texts from CSV..."
  task :create_yaml, [:sourcefile] => [:environment] do |t, args|
    puts "Source file: " + args[:sourcefile]
    #puts "Target file: " + args[:targetfile]

    puts 'terms:'
    File.foreach(args[:sourcefile]).with_index do |line, line_num|
      puts "  - id: #{line_num+1}"
      puts "    term: \"#{line.squish}\""
    end
  end

  # To run this rake task, type:
  # bundle exec rake authorities:create_countries[lib/assets/iso_3166_country_codes.csv] > config/authorities/country_code.yml
  desc "Generating countries YAML from CSV..."
  task :create_countries, [:sourcefile] => [:environment] do |t, args|
    puts 'terms:'
    countries  = Set.new()
    duplicates = Set.new()
    File.foreach(args[:sourcefile]).with_index do |line, line_num|
      next if line_num==0  # bypass the first line which is the title
      #puts "  - id: #{line_num}"
      all_attr = line.squish.split('"')

      if countries.include? all_attr[5].squish
        duplicates << all_attr[5].squish
      end
      countries << all_attr[5].squish
      puts "  - id: #{all_attr[5].squish}"
      puts "    term: \"#{all_attr[1].squish}\""
    end
    if duplicates.length >0
        puts 'ERROR! duplicate detected: ' + duplicates.to_s
    end
  end

  # To run this rake task, type:
  # bundle exec rake authorities:create_us_states[lib/assets/us_states.csv] > config/authorities/us_states.yml
  desc "Generating US states YAML from CSV..."
  task :create_us_states, [:sourcefile] => [:environment] do |t, args|
    puts 'terms:'
    File.foreach(args[:sourcefile]).with_index do |line, line_num|
      next if line_num==0  # bypass the first line which is the title
      puts "  - id: #{line_num}"
      all_attr = line.squish.split(',')
      puts "    abbr: #{all_attr[1].squish}"
      puts "    name: #{all_attr[0].squish}"
    end
  end

  # To run this task, type:
  # bundle exec rake authorities:import_iris_languages[lib/assets/authorities/iris_languages.xml,config/authorities/languages.yml]
  desc "Generating authorities YAML from XML..."
  task :import_iris_languages, [:sourcefile,:targetfile] => [:environment] do |t, args|
    terms = []
    doc = File.open(args[:sourcefile]) { |f| Nokogiri::XML(f) }
    index = 1
    doc.xpath('/languages/language').each do |language|
      label = language.attribute('label')
      terms << {"id"=>index, "term"=>label.to_s}
      index = index + 1
    end
    save_terms_to_file(terms, args[:targetfile])
  end
end