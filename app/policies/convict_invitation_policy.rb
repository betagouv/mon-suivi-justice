class ConvictInvitationPolicy < ApplicationPolicy
  def create?
    record.invitable_to_convict_interface? && user.can_invite_to_convict_interface?
  end
end
