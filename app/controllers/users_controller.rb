class UsersController < ApplicationController
  before_filter :authenticate, :only => [:edit, :index, :update]
  before_filter :correct_user, :only => [:edit, :update]
  before_filter :admin_user, :only => :destroy
  
  def new
	@title = "Sign up"
	@user = User.new
  end
  
  def show
	@user = User.find(params[:id])
	@title = @user.name
  end
  
  def create
	@user = User.new(params[:user])
	if @user.save
		sign_in @user
		flash[:success] = "Welcome to the sample App!"
		redirect_to @user
	else
		@title = "Sign Up"
		render 'new'
	end	
  end
  
  def edit
	@user = User.find(params[:id])
	@title = "Edit User"
  end
  
  def update
	if @user.update_attributes(params[:user])
		flash[:success] = "Profile updated"
		redirect_to @user
	else
		@title = "Edit User"
		render 'edit'
	end
  end
  
  def index
	@title = "All users"
	@users = User.paginate(:page => params[:page])
  end
  private
  
  def authenticate
	deny_access unless signed_in?
  end
  
  def correct_user
	@user = User.find(params[:id])
	redirect_to(root_path) unless current_user?(@user)
  end
  
  def destroy
	user = User.find(params[:id]).destroy
	flash[:success] = "User Destroyed."
	redirect_to user_path
  end
  
  private
  
  def admin_user
	redirect_to(root_path) unless current_user.admin?
  end
end
