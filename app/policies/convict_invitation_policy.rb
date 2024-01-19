class ConvictInvitationPolicy < ApplicationPolicy
  def create?
    return false unless user.security_charter_accepted?

    record.invitable_to_convict_interface? && user.can_invite_to_convict_interface?
  end
end
