module Admin
  class UsersController < ApplicationController
    include ManageCoin
  	before_action :set_user, only: %w[show edit update destroy top_up top_up_process]

    def index
      @q = User.ransack(params[:q])
      @users = @q.result.page(params[:page])
    end

    def show;end

    def edit;end

    def update
      respond_to do |format|
        if @user.update(user_params)
          format.html { redirect_to admin_user_path(@user), notice: 'User was successfully updated.' }
          format.json { render :show, status: :ok, location: @user }
        else
          format.html { render :edit }
          format.json { render json: @user.errors, status: :unprocessable_entity }
        end
      end
    end

    def destroy
    	@user.destroy
      respond_to do |format|
        format.html { redirect_to admin_users_path, notice: 'User was successfully destroyed.' }
        format.json { head :no_content }
      end
    end

    def top_up;end

    def top_up_process
      set_coin(@user)
      incoming_coin(params[:user][:amount].to_i, 'Top up by Admin', {coinable_type: @user.class.to_s, coinable_id: @user.id})
      respond_to do |format|
        format.html { redirect_to admin_users_path, notice: 'User was successfully destroyed.' }
        format.json { head :no_content }
      end
    end

    private
      def set_user
        @user = User.find(params[:id])
      end

      def user_params
      	params[:user][:date_of_birth] = Date.parse(params[:user][:date_of_birth].to_s) if params[:user][:date_of_birth].present?
        params.require(:user).permit!
      end
  end
end