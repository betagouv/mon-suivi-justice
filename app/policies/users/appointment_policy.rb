module Users
  class AppointmentPolicy < ApplicationPolicy
    class Scope < Scope
      def resolve
        if user.cpip? || user.psychologist? || user.overseer?
          scope.includes(:convict, slot: [:appointment_type, { agenda: [:place] }]).where(user: user)
        else
          raise Pundit::NotAuthorizedError
        end
      end
    end
  end
end
