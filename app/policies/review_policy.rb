class ReviewPolicy < ApplicationPolicy
  def create?
    user.present? &&
      not_the_coach? &&
      participated? &&
      not_already_reviewed?
  end

  class Scope < ApplicationPolicy::Scope
    
  end
end
