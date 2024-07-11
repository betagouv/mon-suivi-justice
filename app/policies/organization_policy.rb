class OrganizationPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      elsif user.local_admin?
        scope.where(users: user)
      end
    end
  end

  def index?
    return false unless user.security_charter_accepted?

    user.admin? || user.local_admin?
  end

  def new?
    return false unless user.security_charter_accepted?

    user.admin?
  end

  def edit?
    return false unless user.security_charter_accepted?

    user.admin? || (user.local_admin? && user.organization == record)
  end

  def update?
    return false unless user.security_charter_accepted?

    user.admin? || (user.local_admin? && user.organization == record)
  end

  def create?
    return false unless user.security_charter_accepted?

    user.admin?
  end
end
