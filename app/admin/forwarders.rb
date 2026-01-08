ActiveAdmin.register Forwarder do
  # Set the layout to use the admin layout
  controller do
    layout 'admin'
  end

  # Define permitted parameters for create/update operations
  permit_params :name, :active

  # Define scopes for filtering
  scope :all
  scope :active
  scope :inactive

  # Define filters
  filter :name
  filter :active
  filter :created_at
  filter :updated_at

  # Define the index page
  index do
    selectable_column
    id_column
    column :name
    column :active do |forwarder|
      status_tag forwarder.active? ? "Yes" : "No"
    end
    column :created_at
    column :updated_at
    actions
  end

  # Define the show page
  show do
    attributes_table do
      row :id
      row :name
      row :active do |forwarder|
        status_tag forwarder.active? ? "Yes" : "No"
      end
      row :created_at
      row :updated_at
    end
  end

  # Define the form for create/edit
  form do |f|
    f.inputs 'Forwarder Details' do
      f.input :name, label: 'Forwarder Name', 
              hint: 'Enter the complete name of the forwarder company'
      f.input :active, label: 'Active Status', 
              hint: 'Inactive forwarders will not appear in the selection dropdown'
    end
    f.actions
  end

  # Configure CSV export
  csv do
    column :id
    column :name
    column :active
    column :created_at
    column :updated_at
  end

  # Add batch actions
  batch_action :activate do |ids|
    Forwarder.where(id: ids).update_all(active: true)
    redirect_to collection_path, notice: "Selected forwarders have been activated."
  end

  batch_action :deactivate do |ids|
    Forwarder.where(id: ids).update_all(active: false)
    redirect_to collection_path, notice: "Selected forwarders have been deactivated."
  end

  # Add member action for quick toggle
  member_action :toggle_active, method: :patch do
    resource.update(active: !resource.active)
    redirect_to resource_path, notice: "Forwarder status has been updated."
  end

  # Add action item for toggle button
  action_item :toggle_active, only: :show do
    link_to "Toggle Active Status", toggle_active_admin_forwarder_path(resource), 
            method: :patch, 
            class: "btn btn-primary"
  end
end