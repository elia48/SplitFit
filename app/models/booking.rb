class Booking < ApplicationRecord
  belongs_to :training
  belongs_to :user
  validates :status, presence: true
end
