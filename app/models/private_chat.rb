class PrivateChat < ApplicationRecord
  belongs_to :sender, class_name: "User"
  belongs_to :recipient, class_name: "User"
  has_many :private_messages, dependent: :destroy

  def self.between(user_a, user_b)
    where(sender: user_a, recipient: user_b)
      .or(where(sender: user_b, recipient: user_a))
      .first
  end

  def other_participant(current_user)
    sender == current_user ? recipient : sender
  end
end
