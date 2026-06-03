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
    user.is_coach && record.user == user
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
