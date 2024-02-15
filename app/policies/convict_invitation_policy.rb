class ConvictInvitationPolicy < ApplicationPolicy
  def create?
    if record.persisted?
      record.invitable_to_convict_interface? && user.can_invite_to_convict_interface?(record)
    else
      user.can_invite_to_convict_interface?
    end
  end
end
