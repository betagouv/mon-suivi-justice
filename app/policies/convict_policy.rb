class ConvictPolicy < ApplicationPolicy
  ALLOWED_TO_DESTROY = %w[admin local_admin jap dir_greff_bex dir_greff_sap greff_sap dpip secretary_court].freeze

  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      elsif user.bex? || user.local_admin?
        scope.in_department(user.organization.departments.first)
      else
        scope.under_hand_of(user.organization)
      end
    end
  end

  def index?
    true
  end

  def update?
    true
  end

  def edit?
    record.undiscarded?
  end

  def show?
    true
  end

  def create?
    true
  end

  def archive?
    record.undiscarded?
  end

  def unarchive?
    (user.admin? || user.local_admin?) && record.discarded?
  end

  def destroy?
    ALLOWED_TO_DESTROY.include?(user.role) && record.undiscarded?
  end
end
