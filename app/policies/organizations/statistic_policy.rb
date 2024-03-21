module Organizations
  class StatisticPolicy < ApplicationPolicy
    def index?
      return false unless user.security_charter_accepted?

      (user.admin? || user.local_admin?) && user.organization == record
    end
  end
end
