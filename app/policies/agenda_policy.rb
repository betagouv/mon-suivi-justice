class AgendaPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin? || user.local_admin? || user.work_at_bex?
        scope.in_jurisdiction(user.organization)
      else
        scope.in_organization(user.organization)
      end
    end
  end

  def new?
    user.admin? || user.local_admin? || user.greff_sap?
  end

  def edit?
    user.admin? || user.local_admin? || user.greff_sap?
  end

  def create?
    return false unless user.admin? || user.local_admin? || user.greff_sap?

    record.place.organization == user.organization
  end

  def update?
    return false unless user.admin? || user.local_admin? || user.greff_sap?

    record.place.organization == user.organization
  end

  def destroy?
    return false unless user.admin? || user.local_admin? || user.greff_sap?

    record.place.organization == user.organization
  end

  def can_create_slot_inside?
    if user.admin?
      return [user.organization, *user.organization.linked_organizations].include?(record.place.organization)
    end

    record.place.organization == user.organization
  end
end
