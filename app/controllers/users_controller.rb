class UsersController < ApplicationController
    before_action :authenticate_user!
    before_action :set_user, only: [:edit, :update]
    before_action :authorize_user, only: [:edit, :update]

  
    def dashboard
      if current_user.is_buyer
        redirect_to "/products-list"
      elsif current_user.is_seller
        redirect_to dashboard_path
      else
        redirect_to root_path, alert: 'Invalid role'
      end
    end

    def edit
      @user = User.find_by(id: params[:id])
    end


  def update
    if @user.update(user_params)
      if @user.role == "buyer"
        redirect_to "/products-list", notice: 'Your account has been successfully updated.'
      else
        redirect_to dashboard_path, notice: 'Your account has been successfully updated.'
      end
    else
      flash[:alert] = 'There were errors updating your account. Please check the form.'
      render :edit
    end
  end

    private

    def authorize_user
      unless current_user.id == params[:id].to_i
        flash[:errors] = 'You are not authorized to edit another user’s settings.'
        redirect_to root_path
      end
    end

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:first_name, :last_name, :company_name, :website, :contact_info, :license_number, :address, :license, :password, :password_confirmation,:phone_number, :country_code ,:profile_image)
    end  
  
end