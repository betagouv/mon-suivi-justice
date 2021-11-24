class ConvictPolicy < ApplicationPolicy
  ALLOWED_TO_DESTROY = %w[admin local_admin jap dir_greff_bex dir_greff_sap greff_sap dpip secretary_court].freeze

  class Scope < Scope
    def resolve
      if user.admin?
        scope.with_deleted
      elsif user.local_admin?
        scope.with_deleted.in_department(user.organization.departments.first)
      elsif user.bex? || user.sap?
        scope.in_department(user.organization.departments.first)
      else
        scope.under_hand_of(organization)
      end
    end
  end

  def index?
    true
  end

  def update?
    true
  end

  def show?
    true
  end

  def create?
    true
  end

  def archive?
    true
  end

  def unarchive?
    user.admin? || user.local_admin?
  end

  def destroy?
    ALLOWED_TO_DESTROY.include? user.role
  end
end
