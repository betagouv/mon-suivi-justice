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

  def generate_invitation_link
    @user = User.find(params[:user_id])
    authorize @user

    @invitation_url = "pouet 2"
    render :show
  end

  private

  def user_params
    params.require(:user).permit(
      :first_name, :last_name, :email, :role, :organization_id,
      :password, :password_confirmation, :phone, :share_email_to_convict, :share_phone_to_convict
    )
  end
end
