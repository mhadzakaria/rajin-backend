module Admin
  class SchoolPartnersController < ApplicationController
    before_action :set_school_partner, only: [:show, :edit, :update, :destroy]

    def index
      @q = SchoolPartner.ransack(params[:q])
      @school_partners = @q.result.page(params[:page])
    end

    def show
    end

    def new
      @school_partner = SchoolPartner.new
    end

    def edit
    end

    def create
      @school_partner = SchoolPartner.new(school_partner_params)

      respond_to do |format|
        if @school_partner.save
          format.html { redirect_to admin_school_partner_path(@school_partner), notice: 'School partner was successfully created.' }
          format.json { render :show, status: :created, location: @school_partner }
        else
          format.html { render :new }
          format.json { render json: @school_partner.errors, status: :unprocessable_entity }
        end
      end
    end

    def update
      respond_to do |format|
        if @school_partner.update(school_partner_params)
          format.html { redirect_to admin_school_partner_path(@school_partner), notice: 'School partner was successfully updated.' }
          format.json { render :show, status: :ok, location: @school_partner }
        else
          format.html { render :edit }
          format.json { render json: @school_partner.errors, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      @school_partner.destroy
      respond_to do |format|
        format.html { redirect_to admin_school_partners_path, notice: 'School partner was successfully destroyed.' }
        format.json { head :no_content }
      end
    end

    private
      def set_school_partner
        @school_partner = SchoolPartner.find(params[:id])
      end

      def school_partner_params
        params.require(:school_partner).permit(:name, :phone_number, :full_address, :city, :postcode, :state, :country, :latitude, :longitude)
      end
  end
end