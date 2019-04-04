module Api::V1
  class CoinPackagesController < Api::BaseApiController
    before_action :set_coin_package, only: [:show]

    def index
      @coin_packages = CoinPackage.all
      respond_with @coin_packages, each_serializer: CoinPackageSerializer, status: 200
    end

    def show
      respond_with @coin_package, serializer: CoinPackageSerializer, status: 200
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