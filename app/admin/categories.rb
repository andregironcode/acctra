ActiveAdmin.register Category do
  controller do
    layout 'admin'
  end
  permit_params :name, :brand_id, :device_id
  
  index title: "Models" do
    selectable_column
  
    column :name
    column :brand
    column :device
    actions defaults: false do |record|
      div class: 'dropdown' do
        button class: 'btn btn-primary dropdown-toggle',  type: 'button', data: { toggle: 'dropdown' } do
          'Actions'
        end
        ul class: 'dropdown-menu' do
          li do
            link_to 'View', admin_model_path(record), class: 'dropdown-item'
          end
          li do
            link_to 'Edit', edit_admin_model_path(record), class: 'dropdown-item'
          end
          li do
            link_to 'Delete', admin_model_path(record), method: :delete, data: { confirm: 'Are you sure?' }, class: 'dropdown-item'
          end
        end
      end
    end
  end
  config.clear_action_items!

  action_item :new, only: :index do
    link_to "New Model", new_admin_model_path
  end


  form partial: 'admin/new_category_form'

  filter :name

  # form do |f|
  #   f.inputs "Category Details" do
  #     f.input :name
  #   end
  #   f.actions
  # end

  collection_action :fetch_categories, method: :get do
    device_id = params[:device_id]
    categories = Category.where(device_id: device_id)
    render json: categories.map { |c| { id: c.id, name: c.name, }}
  end
end
