class Users::SessionsController < Devise::SessionsController

 def send_otp
    if request.post?
      user = User.find_by(email: params[:email])
      if user
        user.generate_otp!
        UserMailer.send_otp(user).deliver_now
        redirect_to verify_otp_path(email: user.email)
      end
    end
  
 end

  def verify_otp
    if request.post?
      email = params[:email]
      user = User.find_by(email: email)
      if user && user.otp_valid?(params[:otp])
        user.clear_otp!
        sign_in(user)
        session[:otp_user_id] = nil
        redirect_to root_path, notice: "Signed in successfully."
      else
        flash[:errors] = "Invalid OTP."
        redirect_to verify_otp_path(email: email)

      end
    end
  end
end
