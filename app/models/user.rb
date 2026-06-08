class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_one_attached :avatar
  has_many :written_reviews, class_name: "Review", foreign_key: :user_id, dependent: :nullify
  has_many :received_reviews, class_name: "Review", foreign_key: :coach_id, dependent: :nullify
  has_many :bookings, dependent: :destroy
  has_many :trainings, dependent: :destroy
  has_many :messages, dependent: :destroy
  validates :name, presence: true

  def average_rating
    return nil if received_reviews.empty?

    received_reviews.average(:score).round(1)
  end

  def accessible_chat_trainings
    coach_ids = trainings.joins(:bookings).where(bookings: { status: "paid" }).distinct.pluck(:id)
    member_ids = Training.joins(:bookings).where(bookings: { user: self, status: "paid" }).pluck(:id)
    Training.where(id: (coach_ids + member_ids).uniq).includes(:user, :messages, :photo_attachment, user: :avatar_attachment)
  end

  def chat_count
    accessible_chat_trainings.count
  end
end
