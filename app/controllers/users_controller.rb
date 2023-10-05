class UsersController < ApplicationController
  before_action :authenticate_user!

  def index
    @users = policy_scope(User).order('last_name asc').page params[:page]
    @all_users = policy_scope(User)

    authorize @users
  end

  def show
    @user = User.find(params[:id])
    authorize @user
  end

  def edit
    @user = User.find(params[:id])
    authorize @user
  end

  def update
    @user = User.find(params[:id])
    authorize @user

    if @user.update(user_params)
      remove_linked_convicts(@user)
      redirect_to @user == current_user ? user_path(params[:id]) : users_path
    else
      render :edit
    end
  end

  def destroy
    @user = User.find(params[:id])
    authorize @user
    @user.destroy
    redirect_to users_path
  end

  def invitation_link
    @user = User.find(params[:user_id])
    authorize @user

    @user.invite! { |u| u.skip_invitation = true }
    token = @user.raw_invitation_token

    @invitation_link = request.base_url + "/users/invitation/accept?invitation_token=#{token}"
  end

  def reset_pwd_link
    authorize @user = User.find(params[:user_id])
    authorize @user

    raw_token, hashed_token = Devise.token_generator.generate(User, :reset_password_token)

    if @user.update(reset_password_token: hashed_token, reset_password_sent_at: Time.now.utc)
      @reset_pwd_link = request.base_url + "/users/password/edit?reset_password_token=#{raw_token}"
    else
      redirect_to user_path(@user)
    end
  end

  def stop_impersonating
    authorize current_user
    stop_impersonating_user
    redirect_to admin_root_path
  end

  def search
    @users = policy_scope(User).where(role: %w[cpip dpip]).search_by_name(params[:q])
    authorize @users
    render layout: false
  end

  # rubocop:disable Metrics/MethodLength
  def mutate
    user = User.find(params[:id])
    authorize user

    old_organization = user.organization

    if user.update(organization: current_organization)
      remove_linked_convicts(user, mutation: true)
      remove_linked_appointments(user)
      send_mutation_emails(user, old_organization)

      redirect_to user_path(user), notice: 'L\'agent a bien été muté dans votre service'
    else
      redirect_to users_path, alert: "Erreur lors de la mutation de l'agent : #{user.errors.full_messages}"
    end
  end
  # rubocop:enable Metrics/MethodLength

  private

  def user_params
    params.require(:user).permit(
      :first_name, :last_name, :email, :role, :organization_id,
      :password, :password_confirmation, :phone, :share_email_to_convict, :share_phone_to_convict
    )
  end

  def remove_linked_convicts(user, mutation: false)
    return if %w[cpip dpip].include?(user.role) && !mutation

    user.convicts.each { |c| Convict.update(c.id, user_id: nil) }
  end

  def remove_linked_appointments(user)
    future_appointments = user.appointments.joins(:slot).where('slots.date > ?', Time.zone.today)
    future_appointments.update_all(user_id: nil)
  end

  def send_mutation_emails(user, old_organization)
    UserMailer.notify_mutation(user).deliver_later
    UserMailer.notify_local_admins_of_mutation(user, old_organization).deliver_later
  end
end
