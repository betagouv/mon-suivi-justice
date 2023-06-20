class AppointmentsReschedulesPolicy < ApplicationPolicy
  def new?
    user.organization.in?([record.organization, record.creating_organization])
  end

  def create?
    new?
  end
end
