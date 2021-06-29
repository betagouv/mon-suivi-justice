class ConvictPolicy < ApplicationPolicy
  def index?
    true
  end

  def update?
    user.admin? or user.bex?
  end

  def show?
    true
  end

  def create?
    true
  end

  def destroy?
    user.admin? or user.bex?
  end
end
