class AppointmentPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin? || user.local_admin? || user.work_at_bex?
        # TODO: there is for the moment only one department per organization.
        # When there will be more, this logic will need to be adapted.
        scope.in_department(user.organization.departments.first)
      else
        scope.in_organization(user.organization)
      end
    end
  end

  def index?
    !user.work_at_bex?
  end

  def show?
    true
  end

  def agenda_jap?
    user.admin? || user.local_admin? || user.work_at_sap? || user.work_at_bex?
  end

  def agenda_spip?
    user.admin? || user.local_admin? || user.work_at_bex? || user.work_at_spip?
  end

  def update?
    appointment_workflow
  end

  def new?
    true
  end

  def create?
    true
  end

  def destroy?
    appointment_workflow
  end

  def reschedule?
    appointment_workflow
  end

  def cancel?
    appointment_workflow
  end

  def fulfil?
    appointment_fulfilment
  end

  def miss?
    appointment_fulfilment
  end

  def excuse?
    appointment_fulfilment
  end

  private

  def appointment_workflow
    apt_type = AppointmentType.find(record.slot&.appointment_type_id)

    if user.work_at_sap? then apt_type.used_at_sap?.include? apt_type.name
    elsif user.work_at_spip? then apt_type.used_at_spip?.include? apt_type.name
    elsif user.work_at_bex? then apt_type.used_at_bex?.include? apt_type.name
    else
      true
    end
  end

  def appointment_fulfilment
    apt_type = AppointmentType.find(record.slot&.appointment_type_id)

    if user.work_at_sap? then apt_type.used_at_sap?.include? apt_type.name
    elsif user.work_at_spip? then apt_type.used_at_spip?.include? apt_type.name
    elsif user.work_at_bex? then false
    else
      true
    end
  end
end
