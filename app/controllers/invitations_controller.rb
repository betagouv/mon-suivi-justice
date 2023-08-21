class InvitationsController < Devise::InvitationsController
  layout 'agent_interface', only: [:new, :create]

  # Overriding devise's create action so that admins can move users to other organizations
  def create
    email = invite_params[:email]
    existing_user = User.find_by(email:)

    if existing_user && (existing_user.organization != current_organization)
      redirect_to new_user_invitation_path,
                  alert: "Cet agent fait déjà partie d'un autre service : “#{existing_user.organization.name}”. Si cet agent a été muté dans votre service, vous pouvez effectuer sa mutation en cliquant ici : “Muter l’agent dans mon service”. Un email sera envoyé au service actuel pour l’informer"
      return
    end

    super
  end

  protected

  def after_invite_path_for(_, _)
    users_path
  end

  def after_accept_path_for(_)
    home_path
  end
end
