module Api::V1
  class OrdersController < Api::BaseApiController
    # skip_before_action :authenticate_user!, only: [:ipay88, :ipay88_backend, :ipay88_test]
    # skip_before_action :verify_authenticity_token, only: [:ipay88, :ipay88_backend, :ipay88_test]

    def index
      @job_categories = Order.all
      respond_with @job_categories, each_serializer: OrderSerializer, status: 200
    end

    def show
      respond_with @order, serializer: OrderSerializer, status: 200
    end

    def create
      @order = Order.new(order_params)
      if @order.save
        render json: @order, serialize: OrderSerializer, status: 200
      else
        render json: { error: @order.errors.full_messages }, status: 422
      end
    end

    def update
      if @order.update(order_params)
        render json: @order, serialize: OrderSerializer, status: 200
      else
        render json: { error: @order.errors.full_messages }, status: 422
      end
    end

    def destroy
      @order.destroy
      render json: @order, serialize: OrderSerializer, status: 204
    end

    # def ipay88
    #   Need to change based on rajin belajar app flow
    #   order_id = if params[:RefNo].present?
    #     params[:RefNo].delete("PS")
    #   else
    #     nil
    #   end

    #   @order = Order.find_by(id: order_id)

    #   if @order.present? && @order.user.agent?
    #     @agency = @order.user.agent.agency
    #     @sale = @agency.sale_representatives.first

    #     if @order.user.agent.employee.present?
    #       @order.employee = @order.user.agent.employee
    #     else
    #       @order.employee = @sale || Order.default_sales
    #     end
    #   end

    #   if @order.blank?
    #     render json: {message: "site/bad_request"}, status: 404 and return
    #   elsif @order.paid? && params[:Status] == '1'
    #     # redirect_to credit_purchase_path(conversion: true), notice: 'Your payment has been successfully accepted!'
    #   elsif params[:Status] == '1' && @order.pending? && @order.ipay88_response_code(params[:PaymentId]) == params[:Signature]
    #     @order.net_amount = @order.amount * Order::PROCESSING_RATE_TIER
    #     @order.payment_gateway = :ipay88
    #     @order.ipay88_payment_method(params[:PaymentId])

    #     if @order.strict_change_status(:paid) && @order.save
    #       @order.user.topup_credit(@order.total_credits_awarded)
    #       @order.user.add_transfer_limit(@order.transfer_limit) if @order.promotion_code.present?
    #       @order.user.update_credit_expiry(@order.expiry_date)
    #       @order.bind_custom_employee if @order.promotion_code == 'shahpromo'

    #       redirect_to credit_purchase_path(conversion: true), notice: 'Your payment has been successfully accepted!'
    #     else
    #       render json: {message: "site/bad_request"}, status: 404 and return
    #     end
    #   elsif params[:Status] == '0'
    #     @order.payment_gateway = :ipay88
    #     if @order.strict_change_status(:failed) && @order.save
    #       redirect_to credit_purchase_path, alert: 'Your payment has failed, please try again!'
    #     else
    #       render "site/bad_request", status: 404
    #     end
    #   else
    #     render "site/bad_request", status: 404
    #   end
    # end

    # def ipay88_backend
    #   Need to change based on rajin belajar app flow

    #   order_id = params[:RefNo].delete("PS")
    #   @order = Order.find_by_id(order_id)

    #   if @order.present? && @order.user.agent?
    #     @agency = @order.user.agent.agency
    #     @sale = @agency.sale_representatives.first

    #     if @order.user.agent.employee.present?
    #       @order.employee = @order.user.agent.employee
    #     else
    #       @order.employee = @sale || Order.default_sales
    #     end
    #   end

    #   if @order.blank?
    #     render "site/bad_request", status: 404

    #   elsif params[:Status] == '1' && @order.pending? && @order.ipay88_response_code(params[:PaymentId]) == params[:Signature]
    #     @order.net_amount = @order.amount * Order::PROCESSING_RATE_TIER
    #     @order.payment_gateway = :ipay88
    #     @order.ipay88_payment_method(params[:PaymentId])

    #     if @order.strict_change_status(:paid) && @order.save
    #       @order.user.topup_credit(@order.total_credits_awarded)
    #       @order.user.add_transfer_limit(@order.transfer_limit) if @order.promotion_code.present?
    #       @order.user.update_credit_expiry(@order.expiry_date)
    #       @order.bind_custom_employee if @order.promotion_code == 'shahpromo'

    #       render plain: "RECEIVEOK"
    #     else
    #       render "site/bad_request", status: 404
    #     end
    #   else
    #     render "site/bad_request", status: 404
    #   end
    # end

    # def ipay88_test
    #   Need to change based on rajin belajar app flow
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

    def order_params
      params.require(:order).permit! if params[:order]
    end
  end
end