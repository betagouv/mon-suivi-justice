class ConvictInvitationPolicy < ApplicationPolicy
  def create?
    return false unless user.security_charter_accepted?

    if record.persisted?
      record.invitable_to_convict_interface? && user.can_invite_to_convict_interface?(record)
    else
      user.can_invite_to_convict_interface?(record)
    end
  end
end
