# app/controllers/concerns/search_pure.rb
module CreateDip
  extend ActiveSupport::Concern

  include SearchSolr
  include Exceptions
  included do
    # ???
    attr_reader :dip
  end

  def create_dip(dataset)
    @dip = dataset.aips.first
    # add a temporary uuid so that we can call datasets.dips
    @dip.dip_uuid = 'tbc'
  end

  def save_dip
    @dip.save
  end

  # REVIEW: change/remove this when status.py is doing the updating
  def update_dip(id, uuid)
    begin
      dataset = Dlibhydra::Dataset.find(id)
    rescue => e
      handle_exception(e, "Unable to find dataset. Make sure Solr is running", "Dataset id: " + id)
      raise
    end
    @dip = dataset.aips[0]
    dip_info = get_dip_details(uuid)
    # if dip_info is empty, there was probably an error getting the dip details so just return
    if dip_info.empty?
      return ""
    else
      begin
        ingest_dip(dip_info['current_path'])
      rescue => e
        # ingest dip failed so just return
        return ""
      end
      ingest_dip(dip_info['current_path'])
      dip_current_path(dip_info['current_path'])
      dip_uuid(dip_info['uuid'])
      dip_status(dip_info['status'])
      dip_size(dip_info['size'])
      dip_current_location(dip_info['current_location']) # api location
      dip_resource_uri(dip_info['resource_uri']) # api uri
      dip_size(dip_info['size'])
      dip_origin_pipeline(dip_info['origin_pipeline'])
      save_dip
      'AIP updated with dissemination objects'
    end
  end

  def dip_uuid(uuid)
    @dip.dip_uuid = uuid
  end

  def dip_current_path(value)
    @dip.dip_current_path = value
  end

  def dip_resource_uri(value)
    @dip.dip_resource_uri = value
  end

  def dip_size(value)
    @dip.dip_size = value
  end

  def dip_current_location(value)
    @dip.dip_current_location = value
  end

  def dip_origin_pipeline(value)
    @dip.origin_pipeline = value
  end

  def dip_status(status)
    @dip.dip_status = status
  end

  def requestor_email(value)
    unless @dip.requestor_email.include? value
      emails = @dip.requestor_email.clone
      emails << value
      @dip.requestor_email = emails
      save_dip
    end
  end

  # inside the dip location folder, there will be:
  # - a folder called "objects" containing the actual files of the dip
  # - a folder called "thumbnails" containing thumbnails for each file in the dip
  # - a file called "METS.xxxx.xml"
  # - a file called "ProcessingMCP.xml"
  # Need to create a FileSet for METS.xxxx.xml, a FileSet for Processing.MCP.xml, and a FileSet for each actual file in the dip
  # (which will consist of a primary file (in "objects") and an additional file (in "thumbnails"))
  def ingest_dip(dip_location)
    # uncomment the next 2 lines, and add 2nd parameter "dataid" to the function spec in order to call this method standalone
    # dataset = Dlibhydra::Dataset.find(dataid)
    # @dip = dataset.aips[0]
    location = File.join(ENV['DIP_LOCATION'], dip_location)
    # for each file/folder in the dip location
    Dir.foreach(location) do |item|
      # if it's the "objects" folder
      if File.directory?(File.join(location, item)) && item == 'objects'
        # for each file in the "objects" folder
        Dir.foreach(File.join(location, item)) do |object|
          # skip any directories inside the objects folder
          next if File.directory?(File.join(location, item, object))
          # create a new FileSet
          obj_fs = Dlibhydra::FileSet.new
          # add this file to the FileSet
          obj_fs.preflabel = object
          path = File.join(location, item, object)
          f = open(path)
          Hydra::Works::UploadFileToFileSet.call(obj_fs, f)
          # get the first 36 characters of the filename - the "thumbnail" and "ocr text" corresponding to this file will have this prefix
          prefix = object[0..35]
          # find the "thumbnail" that corresponds to this file (it'll have the same filename prefix) if it exists and add it to the FileSet
          thumbnail_file = prefix + '.jpg'
          thumbnail_path = File.join(location, 'thumbnails', thumbnail_file)
          if File.file?(thumbnail_path)
            f2 = open(thumbnail_path)
            Hydra::Works::AddFileToFileSet.call(obj_fs, f2, :thumbnail, update_existing: false)
          end
          # find the OCR file that corresponds to this file if it exists and add it to the FileSet
          ocrfile = prefix + '.txt'
          ocrfile_path = File.join(location, 'OCRfiles', ocrfile)
          if File.file?(ocrfile_path)
            f3 = open(ocrfile_path)
            Hydra::Works::AddFileToFileSet.call(obj_fs, f3, :extracted_text, update_existing: false)
          end
          # add this FileSet to the dip
          obj_fs.save
          @dip.members << obj_fs
          save_dip
        end
        # otherwise, if it's a file (not a folder)
      elsif File.file?(File.join(location, item))
        # create a new FileSet
        obj_fs = Dlibhydra::FileSet.new
        # add this file to the FileSet
        obj_fs.preflabel = item
        f = open(File.join(location, item))
        Hydra::Works::UploadFileToFileSet.call(obj_fs, f)
        # add this FileSet to the dip
        obj_fs.save
        @dip.members << obj_fs
        save_dip
      end
    end
  rescue => e
    handle_exception(e, "Unable to ingest DIP for given UUID. Make sure you entered the correct UUID and try again", "Given DIP location: " + dip_location)
    raise
  end

  # REVIEW: may not be needed after status.py update
  def get_dip_details(uuid)

    # first of all, make sure we've been given a valid uuid
    if !uuid.match(/^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$/)
      flash[:error] = "You didn't enter a valid UUID"
      return {}
    end

    url = ENV['ARCHIVEMATICA_SS_URL']
    conn = Faraday.new(url: url) do |faraday|
      faraday.request :url_encoded # form-encode POST params
      faraday.response :logger # log requests to STDOUT
      faraday.adapter Faraday.default_adapter # make requests with Net::HTTP
    end

    params = {
      'username' => ENV['ARCHIVEMATICA_SS_USER'],
      'api_key' => ENV['ARCHIVEMATICA_SS_API_KEY']
    }

    begin
      response = conn.get do |req|
        req.url '/api/v2/file/' + uuid + '/'
        req.headers['Accept'] = 'application/json'
        req.params = params
      end
    rescue => e
      handle_exception(e, "Unable to get DIP information: " + e.message, "Error while trying to get dip details for uuid '" + uuid + "'", true) 
      return {}
    end
    # handle case where response wasn't 200 OK
    if response.status and !response.status.to_s.match(/^2\d\d$/)
      begin
        raise
      rescue => e
        begin
          if response.status.to_s == "404"
            handle_exception(e, "Given UUID is not recognised by Archivematica. Make sure you entered it correctly and try again", "404 response from Archivematica for uuid: " + uuid)
          else
            json_response = JSON.parse(response.body)
            handle_exception(e, json_response.message)
          end
        rescue => e2
          if response.body and !response.body.empty?
            handle_exception(e2, "Unable to get DIP details: " + response.body, "UUID input: " + uuid + "\nError from Archivematica: " + response.body, true)
          else
            handle_exception(e2, "Unexpected response from Archivematica. Please try again later", "UUID input: " + uuid, true)
          end
        end
        return {}
      end
    end
    JSON.parse(response.body)

  end

  # Return a has of aip_uuids where dip creation has been approved
  #  but the dip has yet to be uploaded
  def waiting_for_dips
    q = 'dip_status_tesim:APPROVED'
    dips = {}
    num_results = get_number_of_results(q)
    unless num_results == 0
      solr_query_short(q, 'id,aip_uuid_tesim', num_results)['docs'].each do | aip |
        dips[aip['id']] = aip['aip_uuid_tesim'].first
      end
     end
    dips
  rescue => e
    handle_exception(e, "Unexpected error while trying to get DIP information. Please try again later", "UUID input: " + uuid, true)
    return {}
  end


end
