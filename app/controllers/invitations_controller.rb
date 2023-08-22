class InvitationsController < Devise::InvitationsController
  layout 'agent_interface', only: [:new, :create]

  # Overriding devise's create action so that admins can move users to other organizations
  def create
    @user = User.new(invite_params)

    if @user.valid? && @user.errors[:email].blank?
      @user.invite!
      redirect_to some_path, notice: 'Invitation sent!'
    else
      render :new
    end
  end

  protected

  def after_invite_path_for(_, _)
    users_path
  end

  def after_accept_path_for(_)
    home_path
  end
end
