class UsersController < ApplicationController
  before_action :authenticate_user!

  def index
    @users = User.all.order('last_name asc').page params[:page]
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

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :role,
                                 :password, :password_confirmation)
  end
end
