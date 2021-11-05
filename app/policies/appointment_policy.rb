class AppointmentPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin? || user.bex? || user.sap?
        scope.all
      else
        scope.in_organization(organization)
      end
    end
  end

  def index?
    true
  end

  def show?
    true
  end

  def index_today?
    user.admin? || user.local_admin? || user.work_at_spip?
  end

  def agenda_jap?
    user.admin? || user.local_admin? || user.work_at_sap? || user.work_at_bex?
  end

  def agenda_spip?
    true
  end

  def update?
    appointment_workflow
  end

  def new?
    true
  end

  def create?
    appointment_workflow
  end

  def destroy?
    appointment_workflow
  end

  def reschedule?
    true
  end

  def cancel?
    appointment_workflow
  end

  def fulfil?
    appointment_workflow
  end

  def miss?
    appointment_workflow
  end

  def excuse?
    appointment_workflow
  end

  private

  def appointment_workflow
    apt_type = AppointmentType.find(record.slot&.appointment_type_id)

    if user.work_at_sap? then apt_type.used_at_sap?
    elsif user.work_at_bex? then apt_type.used_at_bex?
    elsif user.work_at_spip? then apt_type.used_at_spip?
    else true
    end
  end
end
