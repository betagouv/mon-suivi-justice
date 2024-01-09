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
    true
  end

  def create_divestments_for_convict?
    true
  end
end
