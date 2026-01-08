class Notification < ApplicationRecord
    belongs_to :user
    enum notification_type: { order_update: 'order_update', chat_message: 'chat_message' }
    enum status: { unread: 'unread', read: 'read' }
  end