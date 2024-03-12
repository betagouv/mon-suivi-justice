class BexPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user_has_access?
        scope.in_jurisdiction(user.organization)
      else
        scope.in_organization(user.organization)
      end
    end

    private

    def user_has_access?
      user.admin? || user.local_admin? || user.work_at_bex? || user.work_at_sap?
    end
  end
end
