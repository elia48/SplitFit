class Booking < ApplicationRecord
  belongs_to :training
  belongs_to :user
  validates :status, presence: true
  validates :user, uniqueness: { scope: :training }
  scope :paid, -> { where(status: "paid") }
  scope :pending, -> { where(status: "pending") }
end
