class DivestmentPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      elsif user.local_admin?
        scope.where(users: user)
      end
    end
  end

  def create?
    user.admin? || user.local_admin?
  end
end
