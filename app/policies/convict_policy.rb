class ConvictPolicy < ApplicationPolicy
  ALLOWED_TO_DESTROY = %w[admin local_admin dir_greff_bex dir_greff_sap dpip].freeze

  class Scope < Scope
    def resolve
      if user.work_at_bex?
        scope.all
      else
        # TODO : add linked organizations convicts ?
        scope.joins(:organizations).where(organizations: user.organization)
      end
    end
  end

  def index?
    user.security_charter_accepted?
  end

  def update?
    return false unless user.security_charter_accepted?

    check_ownership?
  end

  def edit?
    return false unless user.security_charter_accepted?

    record.undiscarded? && check_ownership?
  end

  def show?
    return false unless user.security_charter_accepted?

    check_ownership?
  end

  def new?
    user.security_charter_accepted?
  end

  def create?
    return false unless user.security_charter_accepted?

    check_ownership?
  end

  def archive?
    return false unless user.security_charter_accepted?

    record.undiscarded? && check_ownership?
  end

  def unarchive?
    return false unless user.security_charter_accepted?

    (user.admin? || user.local_admin? || user.dir_greff_sap? || user.greff_sap?) && record.discarded?
  end

  def self_assign?
    return false unless user.security_charter_accepted?

    (user.cpip? || user.dpip?) && record.cpip.nil?
  end

  def unassign?
    return false unless user.security_charter_accepted?

    (user.cpip? && record.user == user) || user.dpip? || user.local_admin_spip?
  end

  def destroy?
    return false unless user.security_charter_accepted?

    ALLOWED_TO_DESTROY.include?(user.role) && record.undiscarded? && check_ownership?
  end

  def search?
    user.security_charter_accepted?
  end

  def check_ownership?
    user.work_at_bex? || record.organizations.include?(user.organization)
  end
end
