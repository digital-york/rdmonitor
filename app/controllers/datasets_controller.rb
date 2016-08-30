class DatasetsController < ApplicationController
  before_action :set_dataset, only: [:show]
  include Dlibhydra
  include CreateDataset
  include CreateDip
  include ShowDip

  # GET /datasets
  # GET /datasets.json
  def index

  end

  # GET /datasets/1
  # GET /datasets/1.json
  # GET /datasets/1.zip
  def show
    # a few different cases to deal with here:
    #  - user wants the dataset but hasn't provided an email address
    #  - user wants the dataset and has provided an email address
    #  - user wants a zip download of the dataset files
    @notice = ''
    @dataset = find_dataset(params[:id])
    @dip_files = dip_directory_structure(@dataset)
    if params[:request]
      # handle case where user has just provided an email address
      if params[:request][:email].include? '@'
        @notice = "Thank you. We will send you an email when the data is available."
        create_dip(@dataset)
        set_requestor_email(params[:request][:email])
        save_dip
      # handle case where user hasn't provided an email address
      else
        @notice = 'Please provide a full email address.'
      end
    # handle case where user has requested zip download
    elsif request.format.zip?
      zip_file_stream = dip_as_zip_filestream(@dataset)
    end
    respond_to do |format|
      format.html { render :show, notice: @notice }
      format.json { render :show, status: :created, location: @deposit }
      format.zip { send_data zip_file_stream.read, filename: "dataset.zip" } 
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_dataset
      #@request = Request.new
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def dataset_params
      params.fetch(:dataset, {})
      params.permit(:request, :email)
    end
end
