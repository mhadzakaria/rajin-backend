module Api::V1
  class RolesController < Api::BaseApiController
    before_action :set_role, only: [:show, :destroy, :update]

    def index
      @roles = Role.all
      respond_with @roles, each_serializer: RoleSerializer, status: 200
    end

    def show
      respond_with @role, serializer: RoleSerializer, status: 200
    end

    private

    def set_role
      @role = Role.find(params[:id])
    end

  end
end