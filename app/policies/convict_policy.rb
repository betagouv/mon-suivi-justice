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
    user.admin? or user.bex?
  end

  def destroy?
    user.admin? or user.bex?
  end
end
