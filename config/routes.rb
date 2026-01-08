Rails.application.routes.draw do
  # Devise for ActiveAdmin AdminUser
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)


  namespace :admin do
    resources :inventories do
      collection do
        get :bulk_upload     # Route for the bulk upload form page
        post :import_csv     # Route for the CSV file upload action
        get :devices
        get :models
        get :countries
      end
    end
    resources :products do
      collection do
        get :bulk_upload     # Route for the bulk upload form page
        post :import_csv     # Route for the CSV file upload action
      end
    end
    resources :dashboard, only: [] do
      collection do
        get :recent_orders 
        get :dashboard_filter 
      end
    end
    resources :categories, path: 'models', as: 'models'
    get 'statistics_filter', to: 'statistics#statistics_filter'
    get 'brand_stats_devices', to: 'statistics#brand_stats_devices'
    get 'brand_stats_models', to: 'statistics#brand_stats_models'
    get 'brand_stats_products', to: 'statistics#brand_stats_products'

  end

  # Devise for application Users (Buyers and Sellers)
  devise_for :users, controllers: { registrations: 'users/registrations' , sessions: 'users/sessions'}
  resources :invitations, only: [:new, :create]
  resources :products do
    collection do
      get :fetch_products
      get :fetch_products_countries
    end
  end
  resources :products_inventories, path: 'product-inventories' do
    collection do
      get :bulk_upload
      post :bulk_inventory_upload
    end
  end
  

  devise_scope :user do
    get '/verify-otp', to: 'users/sessions#verify_otp'
    get '/send-otp', to: 'users/sessions#send_otp'
    post '/send-otp', to: 'users/sessions#send_otp'
    post '/verify-otp', to: 'users/sessions#verify_otp'
  end
  
  resources :users, only: [:edit, :update]
  root 'home#home_page'
  get '/role', to: 'users#dashboard'  
  get '/dashboard', to: 'sellers#dashboard', as: 'dashboard'  
  get '/dashboard_filter', to: 'sellers#dashboard_filter'
  get '/stats_filter', to: 'sellers#stats_filter'
  get '/statistics', to: 'sellers#statistics'
  get '/sellers_brand_stats_devices', to: 'sellers#sellers_brand_stats_devices'
  get '/sellers_brand_stats_models', to: 'sellers#sellers_brand_stats_models'
  get '/sellers_brand_stats_products', to: 'sellers#sellers_brand_stats_products'
  get '/orders-list', to: 'sellers#orders_list'
  get '/sellers-fetch-devices', to: 'sellers#devices'
  get '/sellers-fetch-categories', to: 'sellers#categories'
  get '/sellers-fetch-products', to: 'sellers#products'
  post '/update-bid', to: 'sellers#update_bid'
  delete '/delete_item', to: 'buyers#delete_item'
  get '/bids', to: 'sellers#sellers_bids'
  get '/all-bids', to: 'sellers#all_bids'
  post '/upload_imei_sheet', to: 'sellers#upload_imei_sheet'
  get 'upload_imei/:order_id', to: 'sellers#upload_imei', as: 'upload_imei'
  get 'orders-products-details/:order_id', to: 'sellers#products_details', as: 'product_details'
  get '/orders/:id/status', to: 'sellers#update_order_status'
  get '/toggle_approve/:id', to: 'sellers#toggle_approve', as: 'toggle_approve'
  get '/order-details/:id', to: 'sellers#view_order_details', as: 'order_details'
  post '/orders', to: 'orders#create'
  post '/update_status', to: 'orders#update_status'


  get '/products-list', to: 'buyers#products'
  get '/fetch-devices', to: 'buyers#fetch_devices'
  get '/fetch-categories', to: 'buyers#fetch_categories'
  get '/fetch-products', to: 'buyers#fetch_products'
  get '/fetch-inventories', to: 'buyers#fetch_inventories'
  get '/cart', to: 'buyers#cart'
  post '/add-to-cart', to: 'buyers#add_to_cart'
  post '/buyers_bids', to: 'buyers#create_bid'
  patch '/update_cart_items', to: 'buyers#update_cart_items'
  get '/my-orders', to: 'buyers#buyers_orders'
  get '/my-bids', to: 'buyers#buyers_bids'
  post '/consolidate-orders', to: 'buyers#consolidate_orders'
  get '/print', to: 'buyers#print', defaults: { format: 'pdf' }
  get '/print-order', to: 'buyers#print_order', defaults: { format: 'pdf' }
  get '/print-sellers-order', to: 'sellers#print_order', defaults: { format: 'pdf' }
  get '/buyers-faqs', to: 'buyers#faq'
  get '/sellers-faqs', to: 'sellers#faq'

  resources :devices do
    collection do
      get 'fetch_devices', to: 'devices#fetch_devices'
    end
   
  end
  get "up" => "rails/health#show", as: :rails_health_check

  # WhatsApp testing routes
  get '/whatsapp/test', to: 'whatsapp#test_form', as: 'whatsapp_test'
  post '/whatsapp/test_message', to: 'whatsapp#test_message'
  post '/whatsapp/test_kenyan_number', to: 'whatsapp#test_kenyan_number'
  post '/whatsapp/test_templated_message', to: 'whatsapp#test_templated_message'
  post '/whatsapp/send_order_notification', to: 'whatsapp#send_order_notification'
  post '/whatsapp/send_bid_notification', to: 'whatsapp#send_bid_notification'
  get '/whatsapp/config', to: 'whatsapp#configuration_status'
  get 'whatsapp/test_bid_notification', to: 'whatsapp#test_bid_notification'
  post 'whatsapp/send_test_bid_notification', to: 'whatsapp#send_test_bid_notification'
  post 'whatsapp/test_bid_template', to: 'whatsapp#test_bid_template'
  post 'whatsapp/test_order_template', to: 'whatsapp#test_order_template'

  # Define the root path route
  # root "posts#index"
end
