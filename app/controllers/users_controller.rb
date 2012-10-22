class UsersController < ApplicationController
  load_and_authorize_resource

  before_filter :admin_belongs_to_current_org?

  def new
    @user = User.new
  end

  def index
    organization = Organization.find(params[:organization_id])
    @users = organization.field_agents
  end

  def create
    organization = Organization.find(params[:organization_id])
    user = organization.users.new(params[:user])
    user.generate_password
    if user.save
      flash[:notice] = t "users.create.user_created_successfully"
      user.send_password_reset
      redirect_to root_path
    else
      render :new
    end
  end

  private
  def admin_belongs_to_current_org?
    redirect_to(root_path) unless current_user.organization_id.to_s == params[:organization_id]
  end
end
