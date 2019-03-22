module Admin
  class CompaniesController < ApplicationController
    before_action :set_company, only: [:show, :edit, :update, :destroy]

    def index
      @q = Company.ransack(params[:q])
      @companies = @q.result.page(params[:page])
    end

    def show
    end

    def new
      @company = Company.new
    end

    def edit
    end

    def create
      @company = Company.new(company_params)

      respond_to do |format|
        if @company.save
          format.html { redirect_to admin_company_path(@company), notice: 'Company was successfully created.' }
          format.json { render :show, status: :created, location: @company }
        else
          format.html { render :new }
          format.json { render json: @company.errors, status: :unprocessable_entity }
        end
      end
    end

    def update
      respond_to do |format|
        if @company.update(company_params)
          format.html { redirect_to admin_company_path(@company), notice: 'Company was successfully updated.' }
          format.json { render :show, status: :ok, location: @company }
        else
          format.html { render :edit }
          format.json { render json: @company.errors, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      @company.destroy
      respond_to do |format|
        format.html { redirect_to admin_companies_path, notice: 'Company was successfully destroyed.' }
        format.json { head :no_content }
      end
    end

    private
      def set_company
        @company = Company.find(params[:id])
      end

      def company_params
        params.require(:company).permit(:name, :status, :phone_number, :full_address, :city, :postcode, :state, :country, :latitude, :longitude)
      end
  end
end