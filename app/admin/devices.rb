ActiveAdmin.register Device do
  controller do
    layout 'admin'
  end
    permit_params :name, :brand_id
    Formtastic::FormBuilder.perform_browser_validations = true

  
    index do
      selectable_column
      column :name
      column :brand
      actions defaults: false do |record|
        div class: 'dropdown' do
          button class: 'btn btn-primary dropdown-toggle',  type: 'button', data: { toggle: 'dropdown' } do
            'Actions'
          end
          ul class: 'dropdown-menu' do
            li do
              link_to 'View', admin_device_path(record), class: 'dropdown-item'
            end
            li do
              link_to 'Edit', edit_admin_device_path(record), class: 'dropdown-item'
            end
            li do
              link_to 'Delete', admin_device_path(record), method: :delete, data: { confirm: 'Are you sure?' }, class: 'dropdown-item'
            end
          end
        end
      end
    end
  

    form partial: 'admin/new_device_form'

    filter :name
  
    # form do |f|
    #   f.inputs "Brand Details" do
    #     f.input :name
    #   end
    #   f.actions
    # end

    collection_action :fetch_devices, method: :get do
      brand_id = params[:brand_id]
      devices = Device.where(brand_id: brand_id)
      render json: devices.map { |d| { id: d.id, name: d.name, }}
    end
  end
  