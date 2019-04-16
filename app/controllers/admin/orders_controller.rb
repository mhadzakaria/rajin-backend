module Admin
  class OrdersController < ApplicationController
    before_action :set_order, only: [:show, :edit, :update, :destroy]

    include Pundit::Authorization

    def index
      @q = Order.eager_load(:user).ransack(params[:q])
      @orders = @q.result.page(params[:page])
    end

    def show
      @user = @order.user
    end

    private
      def set_order
        @order = Order.find(params[:id])
      end

      def order_params
        params.require(:order).permit(:id, :coin, :amount)
      end
  end
end