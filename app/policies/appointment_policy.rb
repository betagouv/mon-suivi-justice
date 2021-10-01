class AppointmentPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.in_organization(organization)
      end
    end
  end

  def index?
    true
  end

  def index_today?
    user.admin? || user.cpip? || user.sap?
  end

  def agenda_jap?
    user.admin? || user.bex?
  end

  def agenda_spip?
    user.admin? || user.bex?
  end

  def update?
    true
  end

  def show?
    true
  end

  def new_first?
    true
  end

  def create?
    true
  end

  def destroy?
    true
  end

  def cancel?
    true
  end

  def fulfil?
    true
  end

  def miss?
    true
  end
end
