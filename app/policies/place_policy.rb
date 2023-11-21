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
    if user.admin?
      return [user.organization, *user.organization.linked_organizations].include?(record.organization)
    end

    record.organization == user.organization
  end
end
