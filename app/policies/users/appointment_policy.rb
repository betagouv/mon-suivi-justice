module Users
  class AppointmentPolicy < ApplicationPolicy
    class Scope < Scope
      def resolve
        raise Pundit::NotAuthorizedError unless user.cpip? || user.psychologist? || user.overseer?

        scope.includes(:convict, slot: [:appointment_type, { agenda: [:place] }]).where(user: user)
      end
    end
  end
end
