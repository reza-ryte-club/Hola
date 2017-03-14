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
    # @box.date_of_expiry = DateTime.now + (1.0 / 48)
    @base_url = request.base_url
    @base_domain = request.domain
    puts "base url"
    puts @base_url
    puts "base domain"
    puts @base_domain
    last_box = Box.last(1)
    @box.date_of_expiry = Time.now + 1800
    @box.short_file = generate_random_url(last_box[0].id)
    respond_to do |format|
      if @box.save
        message = {filepath: @box.short_file, base_url: @base_url}
        # format.json { render :show, status: :created, location: @box }
        format.json { render json: message, status: :created}
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

  def get_the_file
    short_file = params[:id]
    the_box = Box.find_by(short_file: short_file)
    message = {'message'=> 'file not found'}
    if the_box
      if Time.now.getgm > the_box.date_of_expiry
        message = {'message'=> 'file expired'}
        render json: message
      else
        the_file = the_box.filepath
        redirect_to the_file
      end
    else
      render json: message
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

    def generate_random_url(id)
      timestamp = Time.now.to_i
      result = id.to_s+'lls'+rand(timestamp.to_i..timestamp.to_i+1000.0).to_i.to_s
      return result
    end
end
