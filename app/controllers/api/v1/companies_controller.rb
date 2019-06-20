module Api::V1
  class CompaniesController < Api::BaseApiController
    def verified
      @companies = Company.verified
      respond_with @companies, each_serializer: CompaniesSerializer, status: 200
    end
  end
end