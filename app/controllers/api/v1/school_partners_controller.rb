module Api::V1
  class SchoolPartnersController < Api::BaseApiController
    before_action :set_school_partner, only: [:show, :destroy, :update]

    def index
      @school_partners = SchoolPartner.all
      render json: @school_partners, each_serializer: SchoolPartnerSerializer, status: 200
    end

    def show
      render json: @school_partner, serializer: SchoolPartnerSerializer, status: 200
    end

    def create
      @school_partner = SchoolPartner.new(school_partner_params)
      if @school_partner.save
        render json: @school_partner, serialize: SchoolPartnerSerializer, status: 200
      else
        render json: { error: @school_partner.errors.full_messages }, status: 422
      end
    end

    def update
      if @school_partner.update(school_partner_params)
        render json: @school_partner, serialize: SchoolPartnerSerializer, status: 200
      else
        render json: { error: @school_partner.errors.full_messages }, status: 422
      end
    end

    def destroy
      @school_partner.destroy
      render json: @school_partner, serialize: SchoolPartnerSerializer, status: 204
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