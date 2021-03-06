class ConvictPolicy < ApplicationPolicy
  ALLOWED_TO_DESTROY = %w[admin local_admin jap dir_greff_bex dir_greff_sap greff_sap dpip secretary_court].freeze

  class Scope < Scope
    def resolve
      if user.admin? || user.local_admin? || user.work_at_bex?
        # TODO: there is for the moment only one department per organization.
        # When there will be more, this logic will need to be adapted.
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
    (user.admin? || user.local_admin? || user.dir_greff_sap? || user.greff_sap?) && record.discarded?
  end

  def self_assign?
    (user.cpip? || user.dpip?) && record.cpip.nil?
  end

  def destroy?
    ALLOWED_TO_DESTROY.include?(user.role) && record.undiscarded?
  end
end
