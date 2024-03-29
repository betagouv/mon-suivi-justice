class DivestmentPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      return [] unless user.local_admin?

      scope.where(organization: user.organization)
    end
  end

  def create?
    record.organization == user.organization
  end
end
