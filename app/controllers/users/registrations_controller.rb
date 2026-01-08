# app/controllers/users/registrations_controller.rb
class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_permitted_parameters, if: :devise_controller?

  def new
    @invitation = Invitation.find_by(token: params[:token])
    build_resource
    super
  end
  
  def create
    @invitation = Invitation.find_by(token: params[:token])
    build_resource(sign_up_params)

    if @invitation && params[:user][:email] == @invitation.email
      resource.role = @invitation.role
      resource.save
      if resource.persisted?
        @invitation.update(user_id: resource.id)
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        clean_up_passwords(resource)
        set_minimum_password_length
        respond_with resource
      end
    else
      flash[:alert] = "Invalid invitation token."
      redirect_to new_user_registration_path(token: params[:token])
    end
  end

  protected

  def configure_permitted_parameters
    # Adding additional profile fields to permitted parameters for sign-up and account update
    additional_params = [
      :first_name, :last_name, :contact_info, :company_name, 
      :address, :license_number, :website, :license, :country_code, :phone_number, :profile_image
    ]
    devise_parameter_sanitizer.permit(:sign_up, keys: additional_params)
    devise_parameter_sanitizer.permit(:account_update, keys: additional_params)
  end

  def after_inactive_sign_up_path_for(resource)
    flash[:notice] = "Your account is pending approval. You will be notified once it's approved."
    root_path
  end
end
