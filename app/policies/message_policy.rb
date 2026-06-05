class MessagePolicy < ApplicationPolicy
  def create?
    training = record.training
    return true if training.user == user
    training.bookings.paid.exists?(user: user)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
