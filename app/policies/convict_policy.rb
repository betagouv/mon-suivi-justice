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
    true
  end

  def search?
    true
  end

  def update?
    check_ownership?
  end

  def edit?
    record.undiscarded? && check_ownership?
  end

  def show?
    check_ownership?
  end

  def new?
    true
  end

  def create?
    check_ownership?
  end

  def archive?
    record.undiscarded? && check_ownership?
  end

  def unarchive?
    (user.admin? || user.local_admin? || user.dir_greff_sap? || user.greff_sap?) && record.discarded?
  end

  def self_assign?
    (user.cpip? || user.dpip?) && record.cpip.nil?
  end

  def unassign?
    (user.cpip? && record.user == user) || user.dpip? || user.local_admin_spip?
  end

  def destroy?
    ALLOWED_TO_DESTROY.include?(user.role) && record.undiscarded? && check_ownership?
  end

  def search?
    true
  end

  def check_ownership?
    user.work_at_bex? || record.organizations.include?(user.organization)
  end
end
