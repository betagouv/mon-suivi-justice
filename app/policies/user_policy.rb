class UserPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.in_organization(user.organization)
      end
    end
  end

  def index?
    user.admin? || user.local_admin? || user.dir_greff_bex? || user.dir_greff_sap?
  end

  def update?
    true
  end

  def show?
    true
  end

  def create?
    user.admin? || user.local_admin? || user.dir_greff_bex? || user.dir_greff_sap?
  end

  def destroy?
    user.admin? || user.local_admin? || user.dir_greff_bex? || user.dir_greff_sap?
  end

  def invitation_link?
    user.admin?
  end

  def reset_pwd_link?
    user.admin?
  end

  def stop_impersonating?
    true
  end

  def search?
    true
  end

  def filter?
    index?
  end

  def mutate?
    user.admin? || user.local_admin?
  end
end
