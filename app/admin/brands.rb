ActiveAdmin.register Brand do
  controller do
    layout 'admin'
  end
    permit_params :name
    Formtastic::FormBuilder.perform_browser_validations = true

    index do
      selectable_column
      column :name
      actions defaults: false do |record|
        div class: 'dropdown' do
          button class: 'btn btn-primary dropdown-toggle',  type: 'button', data: { toggle: 'dropdown' } do
            'Actions'
          end
          ul class: 'dropdown-menu' do
            li do
              link_to 'View', admin_brand_path(record), class: 'dropdown-item'
            end
            li do
              link_to 'Edit', edit_admin_brand_path(record), class: 'dropdown-item'
            end
            li do
              link_to 'Delete', admin_brand_path(record), method: :delete, data: { confirm: 'Are you sure?' }, class: 'dropdown-item'
            end
          end
        end
      end
    end
  
    filter :name
  
    form do |f|
      f.inputs "Brand Details" do
        f.input :name
      end
      f.actions
    end

    form partial: 'admin/new_brand_form'

  end
  