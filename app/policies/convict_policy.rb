class ConvictPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin? || user.bex? || user.sap?
        scope.all
      else
        scope.under_hand_of(organization)
      end
    end
  end

  def index?
    true
  end

  def update?
    true
  end

  def show?
    true
  end

  def create?
    true
  end

  def destroy?
    true
  end
end
