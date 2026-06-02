class Message < ApplicationRecord
  belongs_to :training
  belongs_to :user
  validates :content, presence: true
end
