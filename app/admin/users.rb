# app/admin/users.rb
ActiveAdmin.register User do
  controller do
    layout 'admin'
  end
  permit_params :first_name, :last_name, :email, :password, :password_confirmation, :suspended,
  :country_code, :phone_number, :company_name, :address, :license_number, :website, :license, :role, :profile_image

  scope :all
  scope :pending
  scope :approved
  scope :rejected              

  filter :email
  filter :role
  filter :company_name
  filter :website
  filter :approval_status


  form do |f|
    f.inputs "User Details" do
      f.input :first_name
      f.input :last_name
      f.input :email
      f.input :password
      f.input :password_confirmation
      f.input :company_name
      f.input :address
      f.input :license_number
      f.input :website
      f.input :license, as: :file
    end
    f.actions
  end

  form partial: 'admin/new_users_form'


  index do
    selectable_column
    column ' Name' do |user|
      "#{user.first_name} #{user.last_name}"
    end
    column :email
    # column :contact_info
    column :company_name
    column :role
    column 'Contact' do |user|
      "#{user.country_code} #{user.phone_number}"
    end
    # column :address
    # column :license_number
    column :website
    column 'License' do |user|
      if user.license.attached?
        link_to "View License", url_for(user.license), target: "_blank", class: "btn btn-sm btn-outline-primary"
      else
        status_tag "No License", :error
      end
    end
    column :approval_status
    column :suspended
    actions defaults: false do |user|
      div class: 'dropdown' do
        button class: 'btn btn-primary dropdown-toggle', type: 'button', data: { toggle: 'dropdown' } do
          'Actions'
        end
    
        ul class: 'dropdown-menu' do
          li do
            link_to 'View', admin_user_path(user), class: 'dropdown-item'
          end
          li do
            link_to 'Edit', edit_admin_user_path(user), class: 'dropdown-item'
          end
          li do
            link_to 'Delete', admin_user_path(user), method: :delete, data: { confirm: 'Are you sure?' }, class: 'dropdown-item'
          end
          li do
            link_to "Change Password", change_password_admin_user_path(user), class: "dropdown-item"
          end
          if user.pending?
            li do
              link_to "Approve", approve_admin_user_path(user), method: :put, class: "dropdown-item"
            end
            li do
              link_to "Reject", reject_admin_user_path(user), method: :put, class: "dropdown-item"
            end
          elsif user.suspended?
            li do
              link_to "Unsuspend", unsuspend_admin_user_path(user), method: :put, class: "dropdown-item"
            end
          elsif user.approved?
            li do
              link_to "Suspend", suspend_admin_user_path(user), method: :put, class: "dropdown-item"
            end
          end
    
          if user.license.attached?
            li do
              link_to "View License", url_for(user.license), target: "_blank", class: "dropdown-item "
            end
          else
            li do
              "No license"
            end
          end
        end
      end
    end
  end
  

  show do
    attributes_table do
      row :first_name
      row :last_name
      row :email
      row :company_name
      row :address
      # row :license_number
      row :website
      row :license do |user|
        if user.license.attached?
          link_to "View License", url_for(user.license), target: "_blank"
        else
          "No license uploaded"
        end
      end

      row :profile_image do |user|
        if user.profile_image.attached?
          link_to "View profile image", url_for(user.profile_image), target: "_blank"
        else
          "No profile image uploaded"
        end
      end
      row :created_at
      row :updated_at
    end
  end

  member_action :approve, method: :put do
    resource.update(approval_status: :approved)
    redirect_to admin_users_path, notice: "User approved successfully."
  end
  member_action :reject, method: :put do
    resource.update(approval_status: :rejected)
    redirect_to admin_users_path, notice: "User rejected successfully."
  end
  member_action :suspend, method: :put do
    resource.update(suspended: true)
    redirect_to admin_users_path, notice: "User suspended successfully."
  end
  member_action :unsuspend, method: :put do
    resource.update(suspended: false)
    redirect_to admin_users_path, notice: "User unsuspended successfully."
  end

  member_action :change_password, method: :get do
    @user = User.find(params[:id])
    render 'admin/users/change_password'
  end
  member_action :update_password, method: :patch do
    @user = User.find(params[:id])
    user_params = params.require(:user).permit(:password, :password_confirmation)
    if @user.update(user_params)
      redirect_to admin_users_path, notice: "Password updated successfully for #{@user.email}."
    else
      flash[:alert] = @user.errors.full_messages.to_sentence
      render 'admin/users/change_password'
    end
  end
end
