module Admin
  class PicturesController < ApplicationController
    before_action :set_picture, only: [:show, :edit, :update, :destroy]
    before_action :set_object, only: [:new]
    after_action :save_my_previous_url, only: [:new]

    def index
      @q = Picture.ransack(params[:q])
      @pictures = @q.result.page(params[:page])
    end

    def show
    end

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

    def edit
    end

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

    def update
      respond_to do |format|
        if @picture.update(picture_params)
          format.html { redirect_to admin_picture_path(@picture), notice: 'Picture was successfully updated.' }
          format.json { render :show, status: :ok, location: @picture }
        else
          format.html { render :edit }
          format.json { render json: @picture.errors, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      @picture.destroy
      respond_to do |format|
        format.html { redirect_to admin_pictures_path, notice: 'Picture was successfully destroyed.' }
        format.json { head :no_content }
      end
    end

    private
      def set_picture
        @picture = Picture.find(params[:id])
      end

      def set_object
        pictureable_id = params[:pictureable_id]
        pictureable_type = params[:pictureable_type]
        @obj = pictureable_type.singularize.classify.constantize.find(pictureable_id)
      end

      def picture_params
        params.require(:picture).permit(:user_id, :pictureable_type, :pictureable_id, :file_url, :file_type)
      end

      def save_my_previous_url
        session[:my_previous_url] = URI(request.referer || '').path
      end
  end
end
