class BookingPolicy < ApplicationPolicy
  def new?
    show?
  end

  def create?
    return false if record.training.user == user
    return false if record.training.bookings.paid.count >= record.training.max_people
    return false if Booking.exists?(user: user, training: record.training)

    true
  end

  def show?
    record.user == user
  end

  def destroy?
    return false unless record.user == user
    return true if record.status == "pending"
    record.training.bookings.paid.count < record.training.min_people
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.where(user: user)
    end
  end
end
