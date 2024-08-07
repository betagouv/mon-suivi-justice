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
    return false unless user.security_charter_accepted?

    allow_user_actions?
  end

  def update?
    return false unless user.security_charter_accepted?

    check_ownership && authorized_role?
  end

  def show?
    return false unless user.security_charter_accepted?

    check_ownership
  end

  def new?
    return false unless user.security_charter_accepted?

    allow_user_actions?
  end

  def create?
    return false unless user.security_charter_accepted?

    check_ownership && allow_user_actions? && authorized_role?
  end

  def destroy?
    return false unless user.security_charter_accepted?

    return false unless check_ownership && allow_user_actions? && user != record

    !record.admin? || user.admin? # only admin can destroy other admins
  end

  def invitation_link?
    return false unless user.security_charter_accepted?

    user.admin? && user != record
  end

  def reset_pwd_link?
    return false unless user.security_charter_accepted?

    user.admin? && user != record
  end

  def stop_impersonating?
    true
  end

  def search?
    user.security_charter_accepted?
  end

  def filter?
    return false unless user.security_charter_accepted?

    index?
  end

  def mutate?
    return false unless user.security_charter_accepted?

    return false unless user.admin? || user.local_admin?

    record.organization.organization_type == user.organization.organization_type
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

  def authorized_role?
    return true if user.admin?

    record.role != 'admin' # Autorise tous les rôles sauf 'admin' pour les non-administrateurs
  end
end
