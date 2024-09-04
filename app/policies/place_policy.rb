class PlacePolicy < ApplicationPolicy
  ALLOWED_TO_INTERACT = %w[admin local_admin jap dir_greff_bex dir_greff_sap dpip greff_sap].freeze

  class Scope < Scope
    # for the inter ressort to work, we need bex user to be able to access all places of the convict
    # should bex user have access to all places?
    def resolve
      return scope.all if user.can_use_inter_ressort?

      if user.admin? || user.work_at_bex? || user.local_admin_tj?
        scope.in_jurisdiction(user.organization)
      elsif user.work_at_sap?
        scope.joins(:appointment_types).in_organization(user.organization)
             .or(scope.linked_with_ddse(user.organization)).distinct
      else
        scope.in_organization(user.organization)
      end
    end
  end

  def index?
    return false unless user.security_charter_accepted?

    ALLOWED_TO_INTERACT.include?(user.role)
  end

  def new?
    return false unless user.security_charter_accepted?

    ALLOWED_TO_INTERACT.include?(user.role)
  end

  def edit?
    return false unless user.security_charter_accepted?

    check_ownership? && ALLOWED_TO_INTERACT.include?(user.role)
  end

  def update?
    return false unless user.security_charter_accepted?

    check_ownership? && ALLOWED_TO_INTERACT.include?(user.role)
  end

  def show?
    return false unless user.security_charter_accepted?

    check_ownership? && ALLOWED_TO_INTERACT.include?(user.role)
  end

  def create?
    return false unless user.security_charter_accepted?

    check_ownership? && ALLOWED_TO_INTERACT.include?(user.role)
  end

  def archive?
    return false unless user.security_charter_accepted?

    check_ownership? && ALLOWED_TO_INTERACT.include?(user.role)
  end

  def check_ownership?
    return in_user_jurisdiction?(record) if user.admin?

    in_user_organization?(record)
  end

  def in_user_organization?(place)
    place.organization == user.organization
  end

  def in_user_jurisdiction?(place)
    [user.organization, *user.organization.linked_organizations].include?(place.organization)
  end
end
