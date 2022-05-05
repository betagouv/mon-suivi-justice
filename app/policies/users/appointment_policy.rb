class Users::AppointmentPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.joins(:convict).where(convict: {user: user})
    end
  end

  # Ecrire les tests pour la policy
  
  def index?
    user.cpip?
  end
end