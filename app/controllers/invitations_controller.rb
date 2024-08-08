class InvitationsController < Devise::InvitationsController
  layout 'agent_interface', only: [:new, :create]

  def new
    authorize :user, policy_class: UserPolicy
    super
  end

  # Overriding devise's create action so that admins can move users to other organizations
  def create # rubocop:disable Metrics/AbcSize
    @user = User.new(invite_params)
    authorize @user, policy_class: UserPolicy

    existing_user = User.find_by(email: @user.email)
    if existing_user && existing_user.organization != current_user.organization &&
       existing_user.organization.organization_type == current_user.organization.organization_type

      custom_link = mutation_link(existing_user)
      error_message = "est déjà pris par un agent d'un autre service. #{custom_link}".html_safe
      @user.errors.add(:email, error_message)

      render :new, status: :unprocessable_entity
    else
      super
    end
  end

  protected

  def after_invite_path_for(_, _)
    users_path
  end

  def after_accept_path_for(_)
    home_path
  end

  def mutation_link(existing_user)
    mutation_path = Rails.application.routes.url_helpers.mutate_user_path(existing_user)
    view_context.link_to(
      I18n.t('users.mutate.call_to_action'),
      mutation_path,
      data: { 'turbo-confirm': mutation_confirmation_message(existing_user), 'turbo-method': :put }
    )
  end

  def mutation_confirmation_message(existing_user)
    I18n.t('users.mutate.confirmation_message',
           organization_name: existing_user.organization.name,
           phone_number: existing_user.organization.places&.first&.phone)
  end
end
