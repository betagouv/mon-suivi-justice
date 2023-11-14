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
    allow_user_actions?
  end

  def update?
    check_ownership
  end

  def show?
    check_ownership
  end

  def new?
    allow_user_actions?
  end

  def create?
    check_ownership && allow_user_actions?
  end

  def destroy?
    check_ownership && allow_user_actions? && user != record
  end

  def invitation_link?
    user.admin?
  end

  def reset_pwd_link?
    user.admin?
  end

  def stop_impersonating?
    user.admin?
  end

  def search?
    true
  end

  def filter?
    index?
  end

  def mutate?
    return false unless record.organization.organization_type == user.organization.organization_type

    user.admin? || user.local_admin?
  end

  private

  def check_ownership
    return true if user.admin?
    return record.organization == user.organization if user.local_admin? || user.dir_greff_bex? || user.dir_greff_sap?

    user == record
  end

  def allow_user_actions?
    user.admin? || user.local_admin? || user.dir_greff_bex? || user.dir_greff_sap?
  end
end
