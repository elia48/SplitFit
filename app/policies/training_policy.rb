class TrainingPolicy < ApplicationPolicy
  def show?
    true
  end

  def new?
    create?
  end

  def create?
    user.is_coach
  end

  def edit?
    update?
  end

  def update?
    user.is_coach && record.user == user && !%w[cancelled closed].include?(record.status)
  end

  def publish?
    user.is_coach && record.user == user && record.status == "draft"
  end

  def cancel?
    user.is_coach && record.user == user && record.status != "cancelled" && record.status != "draft"
  end

  def access_chat?
    return true if record.user == user

    record.bookings.paid.exists?(user: user)
  end

  def close?
    record.user == user &&
      record.date + record.duration.minutes < Time.current &&
      record.status != "closed"
  end

  def ai_fill?
    create?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.where.not(status: "draft")
    end
  end
end
