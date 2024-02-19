class CityPolicy < ApplicationPolicy
  def services?
    user.security_charter_accepted?
  end

  def search?
    user.security_charter_accepted?
  end
end
