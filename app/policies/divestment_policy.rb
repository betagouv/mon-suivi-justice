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
    record.organization == user.organization
  end

  def create_divestments_for_convict?
    record.organization == user.organization
  end
end
