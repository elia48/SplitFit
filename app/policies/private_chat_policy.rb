class PrivateChatPolicy < ApplicationPolicy
  def show?
    record.sender == user || record.recipient == user
  end

  def create?
    user.present?
  end
end
