require 'aws-sdk'

# This controller has the necesary methods related to uploading files.
class BoxesController < ApplicationController
  S3_BUCKET = Aws::S3::Resource.new.bucket(ENV['S3_BUCKET'])
  before_action :set_box, only: [:show, :edit, :update, :destroy]
  before_action :set_s3_direct_post, only: [:new, :edit, :create, :update]

  def index
    @boxes = Box.all
  end

  def new
    @box = Box.new
  end

  def create
    @box = Box.new(box_params)
    @base_url = request.base_url
    last_box = Box.count>0? Box.last(1):[{id: 0}]
    @box.date_of_expiry = Time.now + 1800
    @box.short_file = Box.count>0?generate_random_url(last_box[0].id):generate_random_url(0)
    @box.is_deleted = false
    respond_to do |format|
      if @box.save
        message = {filepath: @box.short_file, base_url: @base_url}
        format.json { render json: message, status: :created}
      else
        format.json { render json: @box.errors, status: :unprocessable_entity }
      end
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
        # Check whether the file is deleted
        unless the_box.is_deleted
          puts 'file is not deleted hmmmph'
          # Delete the file from the s3
          # get the key value of the deleted file
          the_box.is_deleted = true
          the_box.save
          the_box.filepath.slice! ENV['AWS_URL']
          delete_from_s3(the_box.filepath)
        end
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

    def delete_from_s3 (key)
      S3_BUCKET.delete_objects({
        delete: {
          objects: [
            {
              key: key
            },
          ],
          quiet: false,
        }
      })
    end
end
