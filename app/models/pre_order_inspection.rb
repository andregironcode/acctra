class PreOrderInspection < ApplicationRecord
    belongs_to :order
    enum status: { pending: 'pending', completed: 'completed', canceled: 'canceled' }

    def self.ransackable_attributes(auth_object = nil)
      ["created_at", "id", "id_value", "status", "updated_at"]
    end

  end