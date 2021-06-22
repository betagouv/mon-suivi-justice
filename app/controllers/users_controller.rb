class UsersController < ApplicationController
  before_action :authenticate_user!

  def index
    @users = User.all.page params[:page]
    authorize @users
  end

  def show
    @user = User.find(params[:id])
    authorize @user
  end

  def new
    @user = User.new
    authorize @user
  end

  def create
    @user = User.new(user_params)
    authorize @user

    if @user.save
      redirect_to users_path
    else
      render :new
    end
  end

  def edit
    @user = User.find(params[:id])
    authorize @user
  end

  def update
    @user = User.find(params[:id])
    authorize @user

    if @user.update(user_params)
      redirect_to user_path(params[:id])
    else
      render :edit
    end
  end

  def edit_password
    @user = current_user
    authorize @user
  end

  def update_password
    @user = current_user
    authorize @user

    if @user.update(user_password_params)
      bypass_sign_in(@user)
      redirect_to root_path
    else
      render :edit_password
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

  def user_password_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
