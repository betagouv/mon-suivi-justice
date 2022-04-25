class ConvictInvitationPolicy < ApplicationPolicy
  def create?
    (user.cpip? && record.cpip == user || user.admin?) && record.invitable_to_convict_interface?
  end
end
