class UsersController < ApplicationController
  before_action :logged_in_user, only: %i[index edit update]
  before_action :correct_user, only: %i[edit update]
  # 防止安全漏洞，访问destroy动作
  before_action :admin_user, only: :destroy

  def new
    @user = User.new
  end

  def index
    @users = User.where(activated: true).paginate(page: params[:page], per_page: 5)
  end

  def show
    @user = User.find(params[:id])
  end

  def create
    @user = User.new(user_params)
    if @user.save
      # log_in @user
      UserMailer.account_activation(@user).deliver_now
      # flash[:success] = 'Welcome to ToyApp！'
      # redirect_to @user
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url
    else
      render 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = 'Profile updateed'
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = 'User deleted!'
    redirect_to users_url
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def logged_in_user
    unless logged_in?
      store_location
      flash[:danger] = 'Please log in.'
      redirect_to login_path
    end
  end

  def correct_user
    @user = User.find(params[:id])
    redirect_to login_url unless current_user? @user
  end

  def admin_user
    redirect_to root_url if current_user.blank? || !current_user.admin?
  end
end
