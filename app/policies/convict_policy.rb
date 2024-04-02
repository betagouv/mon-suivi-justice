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

    check_ownership? && convokable?
  end

  def edit?
    return false unless user.security_charter_accepted?

    record.undiscarded? && convokable? && check_ownership?
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
    return false unless convokable?

    record.undiscarded? && check_ownership?
  end

  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  def unarchive?
    return false unless user.security_charter_accepted?
    return false unless record.discarded? && check_ownership?

    user.admin? || user.local_admin? || user.work_at_bex? || user.greff_sap? || user.cpip? || user.dpip? ||
      user.secretary_court? || user.secretary_spip?
  end
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/PerceivedComplexity

  def self_assign?
    return false unless user.security_charter_accepted?

    user.can_follow_convict? && record.cpip.nil? && check_ownership?
  end

  def unassign?
    return false unless user.security_charter_accepted?

    (user.cpip? && record.user == user) || ((user.dpip? || user.local_admin_spip?) && check_ownership?)
  end

  def destroy?
    return false unless user.security_charter_accepted?
    return false unless record.convokable?

    ALLOWED_TO_DESTROY.include?(user.role) && record.undiscarded? && check_ownership?
  end

  def search?
    user.security_charter_accepted?
  end

  def check_ownership?
    user.work_at_bex? || record.organizations.include?(user.organization)
  end

  def convokable?
    return false unless user.security_charter_accepted?
    return true unless record.pending_divestments?

    user.bex? && record.convict.divestment_to?(user.organization)
  end
end
