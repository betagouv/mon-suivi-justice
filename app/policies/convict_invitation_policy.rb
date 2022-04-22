class ConvictInvitationPolicy < ApplicationPolicy
  def create?
    (user.cpip? || user.admin?) && record.invitable_to_convict_interface?
  end
end
