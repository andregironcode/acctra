class ApplicationController < ActionController::Base
    rescue_from CanCan::AccessDenied do |exception|
        flash[:errors] = "You are not authorized to perform this action."
        redirect_to root_path  
      end
end
