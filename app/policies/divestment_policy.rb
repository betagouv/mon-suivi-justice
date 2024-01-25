class DivestmentPolicy < ApplicationPolicy
  def create?
    record.organization == user.organization
  end
end
