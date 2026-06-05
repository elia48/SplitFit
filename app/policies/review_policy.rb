class ReviewPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end

  def create?
    not_the_coach? &&
      participated_in_training? &&
      training_finished? &&
      not_already_reviewed?
  end

  private

  def not_the_coach?
    record.training.user != user
  end

  def training_finished?
    record.training.date + record.training.duration.minutes < Time.current
  end

  def participated_in_training?
    Booking.exists?(
      user: user,
      training: record.training,
      status: "paid"
    )
  end

  def not_already_reviewed?
    !Review.exists?(
      user: user,
      training: record.training
    )
  end
end
