# app/admin/admin_user.rb
ActiveAdmin.register AdminUser do
  controller do
    layout 'admin'
  end
  permit_params :email, :password, :password_confirmation

  index do
    selectable_column
    column :email
    column :sign_in_count
    column :created_at
    actions defaults: false do |record|
      div class: 'dropdown' do
        button class: 'btn btn-primary dropdown-toggle',  type: 'button', data: { toggle: 'dropdown' } do
          'Actions'
        end
        ul class: 'dropdown-menu' do
          li do
            link_to 'View', admin_admin_user_path(record), class: 'dropdown-item'
          end
          li do
            link_to 'Edit', edit_admin_admin_user_path(record), class: 'dropdown-item'
          end
          li do
            link_to 'Delete', admin_admin_user_path(record), method: :delete, data: { confirm: 'Are you sure?' }, class: 'dropdown-item'
          end
        end
      end
    end
  end

  filter :email
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at

  form do |f|
    f.inputs do
      f.input :email
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end
end
