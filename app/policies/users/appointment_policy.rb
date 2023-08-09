module Users
  class AppointmentPolicy < ApplicationPolicy
    class Scope < Scope
      def resolve
        raise Pundit::NotAuthorizedError unless user.can_have_appointments_assigned?

        scope.includes(:convict, slot: [:appointment_type, { agenda: [:place] }]).where(user:)
      end
    end
  end
end
