class PrivateMessage < ApplicationRecord
  belongs_to :private_chat, touch: true
  belongs_to :user
  validates :content, presence: true

  after_create_commit -> {
    broadcast_append_to(
      "private_chat_#{private_chat_id}",
      target: "messages",
      partial: "private_messages/private_message",
      locals: { private_message: self }
    )
  }
end
