class BookingPolicy < ApplicationPolicy
  def create?
    record.training.user != user
  end

  def destroy?
    record.user == user && record.training.bookings.size < record.training.min_people
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.where(user: user)
    end
  end
end
