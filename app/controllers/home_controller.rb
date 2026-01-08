class HomeController < ApplicationController


    def home_page
        if current_user.present?
            redirect_to role_path 
        end
    end

end
