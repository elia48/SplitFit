class Training < ApplicationRecord
  belongs_to :user
  has_many :bookings, dependent: :destroy
  has_many :messages, dependent: :destroy
  has_many :participants, through: :bookings, source: :user
  has_many :reviews, dependent: :nullify
  validates :coach_price_cents, :duration, :date, :place, :workout_type, :status, :min_people, :max_people,
            presence: true
  validates :min_people, numericality: { greater_than_or_equal_to: 2 }

  def current_price_cents
    people_count = bookings.paid.count + 1
    divisor = [people_count, min_people].max

    coach_price_cents / divisor
  end

  def final_price_cents
    paid_count = bookings.paid.count
    divisor = [paid_count, min_people].max

    coach_price_cents / divisor
  end
end
