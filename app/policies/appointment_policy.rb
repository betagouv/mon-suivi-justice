class AppointmentPolicy < ApplicationPolicy
  SAP_APPOINTMENTS = ['RDV BEX SAP', 'RDV de suivi SAP'].freeze
  BEX_APPOINTMENTS = ['RDV BEX SAP', 'RDV BEX SPIP'].freeze
  SPIP_APPOINTMENTS = ['RDV BEX SPIP', '1er RDV SPIP', 'RDV de suivi SPIP'].freeze

  SAP_HABILITATIONS = ['jap', 'secretary_court', 'greff_sap', 'dir_greff_bex', 'dir_greff_sap', 'sap'].freeze
  BEX_HABILITATIONS = ['prosecutor', 'greff_co', 'bex'].freeze
  SPIP_HABILITATIONS = ['cpip', 'educator', 'psychologist', 'overseer', 'dpip', 'secretary_spip'].freeze

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
    user.admin? || user.local_admin? || user.cpip? || user.educator? ||
      user.psychologist? || user.dpip? || user.overseer? || user.secretary_spip?
  end

  def agenda_jap?
    user.admin? || user.local_admin? || user.bex? || user.jap? ||
      user.prosecutor? || user.secretary_court? || user.greff_sap? || user.dir_greff_bex? ||
      user.dir_greff_sap? || user.greff_co? || user.sap?
  end

  def agenda_spip?
    user.admin? || user.local_admin? || user.bex? || user.jap? ||
      user.prosecutor? || user.secretary_court? || user.greff_sap? || user.dir_greff_bex? ||
      user.dir_greff_sap? || user.greff_co? || user.sap? || user.cpip? ||
      user.educator? || user.psychologist? || user.dpip? || user.overseer? || user.secretary_spip?
  end

  def update?
    appointment_workflow
  end

  def create?
    appointment_workflow
  end

  def destroy?
    appointment_workflow
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
    if SAP_HABILITATIONS.include? user.role
      SAP_APPOINTMENTS.include? record.appointment_type.name
    elsif BEX_HABILITATIONS.include? user.role
      BEX_APPOINTMENTS.include? record.appointment_type.name
    elsif SPIP_HABILITATIONS.include? user.role
      SPIP_APPOINTMENTS.include? record.appointment_type.name
    else
      true
    end
  end
end
