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
    user.is_coach && record.user == user && record.status == "draft"
  end

  def publish?
    user.is_coach && record.user == user && record.status == "draft"
  end

  def cancel?
    user.is_coach && record.user == user && record.status != "cancelled" && record.status != "draft"
  end

  def reopen?
    user.is_coach && record.user == user && record.status == "cancelled"
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.where.not(status: "draft")
    end
  end
end
