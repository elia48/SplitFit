class Review < ApplicationRecord
  belongs_to :training, optional: true
  belongs_to :user, optional: true
  belongs_to :coach, class_name: "User", optional: true
  validates :score, :description, presence: true
  validates :user_id,
            uniqueness: {
              scope: :training_id,
              message: "has already reviewed this training"
            }
end
