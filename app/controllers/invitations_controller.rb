# app/controllers/invitations_controller.rb
class InvitationsController < ApplicationController
  before_action :authenticate_admin!

  def create
    # Check if a user with the specified email and role already exists
    existing_user = User.find_by(email: invitation_params[:email], role: invitation_params[:role])

    if existing_user
      redirect_to admin_dashboard_path, alert: 'User with this email and role already exists.'
    else
      @invitation = Invitation.new(invitation_params)
      if @invitation.save
        InvitationMailer.invite_user(@invitation).deliver_now
        redirect_to admin_dashboard_path, notice: 'Invitation sent successfully. Link will expire in 24 hours.'
      else
        render :new
      end
    end
  end

  def accept
    @invitation = Invitation.find_by(token: params[:token])
    
    if @invitation.nil?
      redirect_to root_path, alert: 'Invalid invitation token.'
    elsif @invitation.expired?
      redirect_to root_path, alert: 'This invitation has expired. Please request a new one.'
    else
      # Your existing invitation acceptance logic
    end
  end

  private

  def invitation_params
    params.require(:invitation).permit(:email, :role)
  end
end