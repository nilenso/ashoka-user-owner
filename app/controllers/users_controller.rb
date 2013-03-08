class UsersController < ApplicationController
  load_and_authorize_resource

  def new
    @user = User.new
  end

  def index
    organization = Organization.find(params[:organization_id])
    @users = organization.field_agents
  end

  def create
    organization = Organization.find(params[:organization_id])
    @user = organization.users.new(params[:user])
    @user.generate_password
    if @user.save
      flash[:notice] = t "users.create.user_created_successfully"
      @user.send_password_reset
      redirect_to root_path
    else
      render :new
    end
  end

  def edit
    @user = User.find_by_id(params[:id])
    @organization = @user.organization
  end

  def update
    @user = User.find_by_id(params[:id])
    if @user.update_attributes(params[:user])
      flash[:notice] = t "users.update.user_updated"
      redirect_to organization_users_path, :organization_id => @user.organization_id
    else
      flash[:error] = @user.errors
      render :edit
    end
  end
end
