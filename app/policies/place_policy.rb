class PlacePolicy < ApplicationPolicy
  ALLOWED_TO_EDIT = %w[admin local_admin jap dir_greff_bex dir_greff_sap dpip greff_sap].freeze

  class Scope < Scope
    # for the inter ressort to work, we need bex user to be able to access all places of the convict
    # should bex user have access to all places?
    def resolve
      return scope.all if user.work_at_bex? && user.organization.use_inter_ressort

      if user.admin? || user.work_at_bex? || user.local_admin_tj?
        scope.in_jurisdiction(user.organization)
      elsif user.work_at_sap?
        scope.joins(:appointment_types).in_organization(user.organization).or(scope.linked_with_ddse(user.organization))
      else
        scope.in_organization(user.organization)
      end
    end
  end

  def index?
    ALLOWED_TO_EDIT.include?(user.role)
  end

  def new?
    ALLOWED_TO_EDIT.include?(user.role)
  end

  def edit?
    check_ownership? && ALLOWED_TO_EDIT.include?(user.role)
  end

  def update?
    check_ownership? && ALLOWED_TO_EDIT.include?(user.role)
  end

  def show?
    check_ownership? && ALLOWED_TO_EDIT.include?(user.role)
  end

  def create?
    check_ownership? && ALLOWED_TO_EDIT.include?(user.role)
  end

  def destroy?
    check_ownership? && ALLOWED_TO_EDIT.include?(user.role)
  end

  def archive?
    check_ownership? && ALLOWED_TO_EDIT.include?(user.role)
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
