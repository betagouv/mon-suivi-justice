class PlacePolicy < ApplicationPolicy
  ALLOWED_TO_EDIT = %w[admin local_admin jap dir_greff_bex dir_greff_sap dpip greff_sap].freeze

  class Scope < Scope
    def resolve
      if user.admin?
        scope.in_jurisdiction(user.organization)
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
    ALLOWED_TO_EDIT.include?(user.role)
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
