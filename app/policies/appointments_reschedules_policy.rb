class AppointmentsReschedulesPolicy < ApplicationPolicy
  def new?
    user_role_allowed? && user.organization.in?([record.organization, record.creating_organization])
  end

  def create?
    new?
  end

  private

  def user_role_allowed?
    user.local_admin? || user.work_at_bex? || user.work_at_sap?
  end
end
