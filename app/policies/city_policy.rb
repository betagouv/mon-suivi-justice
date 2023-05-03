class CityPolicy < ApplicationPolicy
  def services?
    true
  end

  def search?
    true
  end
end
