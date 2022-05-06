module Users
  class AppointmentPolicy < ApplicationPolicy
    class Scope < Scope
      def resolve
        scope.includes(:convict, slot: [:appointment_type, { agenda: [:place] }]).where(convict: { user: user })
      end
    end

    def index?
      user.cpip?
    end
  end
end
