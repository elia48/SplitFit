class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :reviews, dependent: :destroy
  has_many :bookings, dependent: :destroy
  has_many :trainings, dependent: :destroy
  has_many :messages, dependent: :destroy
  validates :name, :is_coach, presence: true
end
