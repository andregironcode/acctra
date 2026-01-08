# db/migrate/[timestamp]_add_expires_at_to_invitations.rb
class AddExpiresAtToInvitations < ActiveRecord::Migration[7.1]
    def change
      add_column :invitations, :expires_at, :datetime
      
      # Set expiration for existing invitations (24 hours from now)
      Invitation.update_all(expires_at: 24.hours.from_now)
    end
  end