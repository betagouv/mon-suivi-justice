class InvitationsController < Devise::InvitationsController
  layout 'agent_interface', only: [:new]

  protected

  def after_invite_path_for(_, _)
    users_path
  end

  def after_accept_path_for(_)
    convicts_path
  end
end
