require 'aws-sdk'

# This controller has the necesary methods related to uploading files.
class BoxesController < ApplicationController
  S3_BUCKET = Aws::S3::Resource.new.bucket(ENV['S3_BUCKET'])
  before_action :set_box, only: [:show, :edit, :update, :destroy]
  before_action :set_s3_direct_post, only: [:new, :edit, :create, :update]

  # GET /boxes
  # GET /boxes.json
  def index
    @boxes = Box.all
  end

  # GET /boxes/1
  # GET /boxes/1.json
  # def show
  #   # code related to the
  # end
  # GET /boxes/new
  def new
    @box = Box.new
  end

  # GET /boxes/1/edit
  # def edit
  # end

  # POST /boxes
  # POST /boxes.json
  def create
    @box = Box.new(box_params)
    # 30 minutes later
    @box.date_of_expiry = DateTime.now + (1.0 / 48)
    respond_to do |format|
      if @box.save
        format.json { render :show, status: :created, location: @box }
      else
        format.json { render json: @box.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /boxes/1
  # PATCH/PUT /boxes/1.json
  def update
    respond_to do |format|
      if @box.update(box_params)
        format.html { redirect_to @box, notice: 'Box was updated.' }
        format.json { render :show, status: :ok, location: @box }
      else
        format.html { render :edit }
        format.json { render json: @box.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /boxes/1
  # DELETE /boxes/1.json
  def destroy
    @box.destroy
    respond_to do |format|
      format.html { redirect_to boxes_url, notice: 'Box was destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_box
      @box = Box.find(params[:id])
    end

    # Never trust parameters from the scary internet,
    # only allow the white list through.
    def box_params
      params.require(:box).permit(:filename, :filepath, :date_of_expiry)
    end

    def set_s3_direct_post
      @s3_direct_post = S3_BUCKET.presigned_post(key: "uploads/#{SecureRandom.uuid}/${filename}", success_action_status: '201', acl: 'public-read')
    end
end
