class Training < ApplicationRecord
  belongs_to :user
  has_many :bookings, dependent: :destroy
  has_many :messages, dependent: :destroy
  has_many :users
  has_many :reviews
  validates :coach_price, :duration, :date, :duration, :place, :workout_type, :status, :min_people, :max_people,
            presence: true

  def price_per_person
    if self.bookings.size > self.min_people
       self.coach_price / self.bookings.size
    else
       self.coach_price / self.min_people
    end
  end
end
