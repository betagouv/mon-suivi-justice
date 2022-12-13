class AppointmentPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin? || user.local_admin? || user.work_at_bex?
        scope.in_departments(user.organization.departments)
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

  def agenda_sap_ddse?
    user.admin? || user.local_admin? || user.work_at_sap? || user.work_at_spip?
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

  def rebook?
    appointment_fulfilment
  end

  def prepare?
    true
  end

  def fulfil_old?
    appointment_fulfilment(allow_old: true)
  end

  def excuse_old?
    appointment_fulfilment(allow_old: true)
  end
  private

  def appointment_workflow
    apt_type = AppointmentType.find(record.slot&.appointment_type_id)

    if user.work_at_sap? then AppointmentType.used_at_sap?.include? apt_type.name
    elsif user.work_at_spip? then AppointmentType.used_at_spip?.include? apt_type.name
    elsif user.work_at_bex? then AppointmentType.used_at_bex?.include? apt_type.name
    else
      true
    end
  end

  def appointment_fulfilment(allow_old: false)
    apt_type = AppointmentType.find(record.slot&.appointment_type_id)
    
    today = Date.today
    six_m_before_today = today - 6
    is_too_old = allow_old ? false : record.slot.date < six_m_before_today;


    return false if record.slot.place.organization != user.organization || is_too_old

    if user.work_at_sap? then AppointmentType.used_at_sap?.include? apt_type.name
    elsif user.work_at_spip? then AppointmentType.used_at_spip?.include? apt_type.name
    elsif user.work_at_bex? then false
    else
      true
    end
  end
end
