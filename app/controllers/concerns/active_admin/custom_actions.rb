# app/controllers/concerns/active_admin/custom_actions.rb
module ActiveAdmin::CustomActions
  extend ActiveSupport::Concern

  included do
    # Define your custom actions or filters here
    # before_action :custom_action_example
  end

  private

  def custom_action_example
    # Custom action logic
  end
end

# config/initializers/active_admin_customization.rb
ActiveSupport.on_load(:active_admin_controller) do
  ActiveAdmin::BaseController.include ActiveAdmin::CustomActions
end
