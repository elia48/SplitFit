class Review < ApplicationRecord
  belongs_to :training
  belongs_to :user
  validates :score, :description, presence: true
  validates :description, :description, presence: true
end
