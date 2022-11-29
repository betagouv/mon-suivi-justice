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
    user.admin? || user.local_admin?
  end

  def show?
    user.admin?
  end

  def new?
    user.admin?
  end

  def edit?
    user.admin? || (user.local_admin? && user.organization == record)    
  end

  def update?
    user.admin? || (user.local_admin? && user.organization == record)
  end

  def create?
    user.admin?
  end

  def destroy?
    user.admin?
  end
end
