module Admin
  class CoinPackagesController < ApplicationController
    before_action :set_coin_package, only: [:show, :edit, :update, :destroy]

    def index
      @q = CoinPackage.ransack(params[:q])
      @coin_packages = @q.result.page(params[:page])
    end

    def show
    end

    def new
      @coin_package = CoinPackage.new
    end

    def edit
    end

    def create
      @coin_package = CoinPackage.new(coin_package_params)

      respond_to do |format|
        if @coin_package.save
          format.html { redirect_to admin_coin_package_path(@coin_package), notice: 'School partner was successfully created.' }
          format.json { render :show, status: :created, location: @coin_package }
        else
          format.html { render :new }
          format.json { render json: @coin_package.errors, status: :unprocessable_entity }
        end
      end
    end

    def update
      respond_to do |format|
        if @coin_package.update(coin_package_params)
          format.html { redirect_to admin_coin_package_path(@coin_package), notice: 'School partner was successfully updated.' }
          format.json { render :show, status: :ok, location: @coin_package }
        else
          format.html { render :edit }
          format.json { render json: @coin_package.errors, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      @coin_package.destroy
      respond_to do |format|
        format.html { redirect_to admin_coin_packages_path, notice: 'School partner was successfully destroyed.' }
        format.json { head :no_content }
      end
    end

    private
      def set_coin_package
        @coin_package = CoinPackage.find(params[:id])
      end

      def coin_package_params
        params.require(:coin_package).permit(:id, :coin, :amount)
      end
  end
end