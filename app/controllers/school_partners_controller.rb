class SchoolPartnersController < ApplicationController
  before_action :set_school_partner, only: [:show, :edit, :update, :destroy]

  # GET /school_partners
  # GET /school_partners.json
  def index
    @q = SchoolPartner.ransack(params[:q])
    @school_partners = @q.result.page(params[:page])
  end

  # GET /school_partners/1
  # GET /school_partners/1.json
  def show
  end

  # GET /school_partners/new
  def new
    @school_partner = SchoolPartner.new
  end

  # GET /school_partners/1/edit
  def edit
  end

  # POST /school_partners
  # POST /school_partners.json
  def create
    @school_partner = SchoolPartner.new(school_partner_params)

    respond_to do |format|
      if @school_partner.save
        format.html { redirect_to @school_partner, notice: 'School partner was successfully created.' }
        format.json { render :show, status: :created, location: @school_partner }
      else
        format.html { render :new }
        format.json { render json: @school_partner.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /school_partners/1
  # PATCH/PUT /school_partners/1.json
  def update
    respond_to do |format|
      if @school_partner.update(school_partner_params)
        format.html { redirect_to @school_partner, notice: 'School partner was successfully updated.' }
        format.json { render :show, status: :ok, location: @school_partner }
      else
        format.html { render :edit }
        format.json { render json: @school_partner.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /school_partners/1
  # DELETE /school_partners/1.json
  def destroy
    @school_partner.destroy
    respond_to do |format|
      format.html { redirect_to school_partners_url, notice: 'School partner was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_school_partner
      @school_partner = SchoolPartner.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def school_partner_params
      params.require(:school_partner).permit(:name, :phone_number, :full_address, :city, :postcode, :state, :country, :latitude, :longitude)
    end
end
