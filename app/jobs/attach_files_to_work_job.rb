# Converts UploadedFiles into FileSets and attaches them to works.
class AttachFilesToWorkJob < Hyrax::ApplicationJob
  queue_as Hyrax.config.ingest_queue_name

  # @param [ActiveFedora::Base] work - the work object
  # @param [Array<Hyrax::UploadedFile>] uploaded_files - an array of files to attach
  def perform(work, uploaded_files, **work_attributes)
    validate_files!(uploaded_files)
    user = User.find_by_user_key(work.depositor) # BUG? file depositor ignored
    work_permissions = work.permissions.map(&:to_hash)
    metadata = visibility_attributes(work_attributes)


    # If the first element is not PDF, try to swap it with the first pdf in the array
    oasis_pdf_first(uploaded_files)

    uploaded_files.each do |uploaded_file|
      actor = Hyrax::Actors::FileSetActor.new(FileSet.create, user)
      actor.create_metadata(metadata)
      actor.create_content(uploaded_file)
      actor.attach_to_work(work)
      actor.file_set.permissions_attributes = work_permissions
      uploaded_file.update(file_set_uri: actor.file_set.uri)
    end
  end

  private
    # If the first element is not PDF, try to swap it with the first pdf in the array
    def oasis_pdf_first(uploaded_files)
      if !uploaded_files[0].file.to_s.downcase.ends_with? '.pdf'
        pdf_index = -1
        uploaded_files.each_with_index do |uploaded_file,index|
          if uploaded_file.file.to_s.downcase.ends_with? '.pdf'
            pdf_index = index
            break
          end
        end
        if pdf_index > 0
          # Swap array elements
          uploaded_files[0],uploaded_files[pdf_index] =  uploaded_files[pdf_index],uploaded_files[0]
        end
      end
    end


    # The attributes used for visibility - sent as initial params to created FileSets.
    def visibility_attributes(attributes)
      attributes.slice(:visibility, :visibility_during_lease,
                       :visibility_after_lease, :lease_expiration_date,
                       :embargo_release_date, :visibility_during_embargo,
                       :visibility_after_embargo)
    end

    def validate_files!(uploaded_files)
      uploaded_files.each do |uploaded_file|
        next if uploaded_file.is_a? Hyrax::UploadedFile
        raise ArgumentError, "Hyrax::UploadedFile required, but #{uploaded_file.class} received: #{uploaded_file.inspect}"
      end
    end
end
