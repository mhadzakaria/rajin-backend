module Api::V1
  class OrdersController < Api::BaseApiController
    include ManageCoin

    self.login_user_type = :user

    skip_before_action :check_login_time, only: [:ipay88, :ipay88_backend]
    before_action :set_order, only: [:show]

    def index
      @orders = current_user.orders.order(id: :asc)
      render json: @orders, each_serializer: OrderSerializer, base_url: request.base_url, status: 200
    end

    def show
      render json: @order, serializer: OrderSerializer, base_url: request.base_url, status: 200
    end

    def create
      @package      = CoinPackage.find(params[:coin_package_id])
      @order        = current_user.orders.new
      @order.amount = @package.amount
      @order.orderable_id   = @package.id
      @order.orderable_type = @package.class.name

      if @order.save
        render json: @order, serialize: OrderSerializer, base_url: request.base_url, status: 200
      else
        render json: { error: @order.errors.full_messages }, status: 422
      end
    end

    # def update
    #   if @order.update(order_params)
    #     render json: @order, serialize: OrderSerializer, status: 200
    #   else
    #     render json: { error: @order.errors.full_messages }, status: 422
    #   end
    # end

    # def destroy
    #   @order.destroy
    #   render json: @order, serialize: OrderSerializer, status: 204
    # end

    def ipay88
      order_id = params[:RefNo].try(:gsub, "PS", "")
      @order   = Order.find_by(id: order_id)
      @user    = @order.try(:user)
      @package = @order.try(:orderable)

      # make sure the order not blank and orderable is coin package
      if @order.blank? || !@package.class.name.eql?("CoinPackage")
        render json: {message: "site/bad_request"}, status: 400 and return
      elsif @order.paid? && params[:Status].eql?('1')
        # condition if order has been paid before
        render json: @order, serializer: OrderSerializer, base_url: request.base_url, status: 200
      elsif params[:Status].eql?('1') && @order.pending? && @order.ipay88_response_code(params[:PaymentId]).eql?(params[:Signature])
        # condition if order still pending / not paid
        @order.net_amount      = @package.amount * Order::PROCESSING_RATE_TIER
        @order.payment_gateway = :ipay88
        @order.ipay88_payment_method(params[:PaymentId])
        @order.ipay88_payment_id

        if @order.strict_change_status(:paid) && @order.save
          @order.reload
          set_coin(@user)
          incoming_coin(@package.coin, "Top up!", {coinable_type: @user.class.name, coinable_id: @user.id})
          render json: @order, serializer: OrderSerializer, base_url: request.base_url, status: 200
        else
          render json: {message: "site/bad_request"}, status: 400 and return
        end
      elsif params[:Status].eql?('0')
        # condition if payment was failed
        @order.payment_gateway = :ipay88
        if @order.strict_change_status(:failed) && @order.save
          render json: {message: "Your payment has failed, please try again!"}, status: 404 and return
        else
          render json: {message: "site/bad_request"}, status: 400 and return
        end
      else
        render json: {message: "site/bad_request"}, status: 400 and return
      end
    end

    def ipay88_backend
      order_id = params[:RefNo].try(:gsub, "PS", "")
      @order   = Order.find_by(id: order_id)
      @user    = @order.try(:user)
      @package = @order.try(:orderable)

      # make sure the order not blank and orderable is coin package
      if @order.blank? || !@package.class.name.eql?("CoinPackage")
        render json: {message: "site/bad_request"}, status: 400 and return
      elsif @order.paid? && params[:Status].eql?('1')
        # condition if order has been paid before
        render plain: "RECEIVEOK"
      elsif params[:Status].eql?('1') && @order.pending? && @order.ipay88_response_code(params[:PaymentId]).eql?(params[:Signature])
        # condition if order still pending / not paid
        @order.net_amount      = @package.amount * Order::PROCESSING_RATE_TIER
        @order.payment_gateway = :ipay88
        @order.ipay88_payment_method(params[:PaymentId])
        @order.ipay88_payment_id

        if @order.strict_change_status(:paid) && @order.save
          set_coin(@user)
          incoming_coin(@package.coin, "Top up!", {coinable_type: @user.class.name, coinable_id: @user.id})
          render plain: "RECEIVEOK"
        else
          render json: {message: "site/bad_request"}, status: 400 and return
        end
      else
        render json: {message: "site/bad_request"}, status: 400 and return
      end
    end

    # def ipay88_test
    #   # Need to change based on rajin belajar app flow
    #   @order = Order.new(order_params)

    #   if request.post?
    #     @order.user = User.first
    #     @order.category = 'Credits'

    #     if @order.save
    #       @description = "ipay88 testing"
    #       # @description = @order.description
    #       render 'ipay88_test_redirection', layout: false
    #     end
    #   else
    #     render :layout => false
    #   end
    # end

    private

    def set_order
      @order = Order.find(params[:id])
    end

    # def order_params
    #   params.require(:order).permit! if params[:order]
    # end
  end
end