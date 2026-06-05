class Message < ApplicationRecord
  belongs_to :training
  belongs_to :user
  validates :content, presence: true

  after_create_commit -> {
    broadcast_append_to(
      "training_chat_#{training_id}",
      target: "messages",
      partial: "messages/message",
      locals: { message: self }
    )
  }
end
