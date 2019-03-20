class PicturesController < ApplicationController
  before_action :set_picture, only: [:show, :edit, :update, :destroy]
  before_action :set_object, only: [:new]
  after_action :save_my_previous_url, only: [:new]

  # GET /pictures
  # GET /pictures.json
  def index
    @q = Picture.ransack(params[:q])
    @pictures = @q.result.page(params[:page])
  end

  # GET /pictures/1
  # GET /pictures/1.json
  def show
  end

  # GET /pictures/new
  def new
    if params[:pictureable_type] == "Job"
      @picture = @obj.pictures.build
    else
      @picture = @obj.build_picture
      if params[:pictureable_type] == "User"
        @picture.user_id = @obj.id
      end
    end
  end

  # GET /pictures/1/edit
  def edit
  end

  # POST /pictures
  # POST /pictures.json
  def create
    @picture = Picture.new(picture_params)

    respond_to do |format|
      if @picture.save
        format.html { redirect_to session[:my_previous_url], notice: 'Picture was successfully created.' }
        format.json { render :show, status: :created, location: @picture }
      else
        format.html { render :new }
        format.json { render json: @picture.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /pictures/1
  # PATCH/PUT /pictures/1.json
  def update
    respond_to do |format|
      if @picture.update(picture_params)
        format.html { redirect_to @picture, notice: 'Picture was successfully updated.' }
        format.json { render :show, status: :ok, location: @picture }
      else
        format.html { render :edit }
        format.json { render json: @picture.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pictures/1
  # DELETE /pictures/1.json
  def destroy
    @picture.destroy
    respond_to do |format|
      format.html { redirect_to pictures_url, notice: 'Picture was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_picture
      @picture = Picture.find(params[:id])
    end

    def set_object
      pictureable_id = params[:pictureable_id]
      pictureable_type = params[:pictureable_type]
      @obj = pictureable_type.singularize.classify.constantize.find(pictureable_id)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def picture_params
      params.require(:picture).permit(:user_id, :pictureable_type, :pictureable_id, :file_url, :file_type)
    end

    def save_my_previous_url
      session[:my_previous_url] = URI(request.referer || '').path
    end
end
