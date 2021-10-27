class ConvictPolicy < ApplicationPolicy
  ALLOWED_TO_DESTROY = %w[admin local_admin jap dir_greff_bex dir_greff_sap greff_sap dpip secretary_court].freeze

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
    ALLOWED_TO_DESTROY.include? user.role
  end
end
