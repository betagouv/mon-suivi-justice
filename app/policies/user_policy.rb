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
    p record
    p user
    check_ownership
  end

  def show?
    check_ownership
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

  private

  def check_ownership
    return record.organization == user.organization if user.local_admin? || user.dir_greff_bex? || user.dir_greff_sap?

    user == record
  end
end
