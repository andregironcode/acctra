ActiveAdmin.register Invitation do
  controller do
    layout 'admin'
  end
  permit_params :email, :role

  index do
    selectable_column
    column :email
    column :role
    column :token
    column :created_at
    actions defaults: false do |record|
      div class: 'dropdown' do
        button class: 'btn btn-primary dropdown-toggle',  type: 'button', data: { toggle: 'dropdown' } do
          'Actions'
        end
        ul class: 'dropdown-menu' do
          li do
            link_to 'View', admin_invitation_path(record), class: 'dropdown-item'
          end
          li do
            link_to 'Edit', edit_admin_invitation_path(record), class: 'dropdown-item'
          end
          li do
            link_to 'Delete', admin_invitation_path(record), method: :delete, data: { confirm: 'Are you sure?' }, class: 'dropdown-item'
          end
        end
      end
    end
  end

  filter :email
  filter :role
  filter :created_at

  # form do |f|
  #   f.inputs do
  #     f.input :email
  #     f.input :role, as: :select, collection: %w[buyer seller]
  #   end
  #   f.actions
  # end
  form partial: 'admin/new_invitations_form'


  # After create, send an email invitation
  after_create do |invitation|
    InvitationMailer.invite_user(invitation).deliver_now
  end
end
