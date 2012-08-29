class OrganizationsController < ApplicationController

  before_filter :require_admin, :only => [ :index, :approve ]

	def new
		@organization = Organization.new()
		@organization.users << User.new()
	end

	def create
    @organization = Organization.new(params[:organization])
    cso_admin = @organization.users.first
    cso_admin.role = "cso_admin" if cso_admin.present?

    if @organization.save
      redirect_to root_path
      flash[:notice] = "Your organization has been created but pending approval. You will recieve a mail when it is approved."
    else
      flash[:error] = "Organization creation failed"
      render :new
    end
	end

  def index
    @organizations = Organization.all
  end

  def approve
    organization = Organization.find(params[:organization_id])
    organization.status = "approved"
    organization.save
    flash[:notice] = organization.name + " is approved!"
    redirect_to organizations_path
  end

  private

  def require_admin
    if !has_signed_in_user?
      flash[:error] = "Please login"
      redirect_to(login_path)
    elsif !current_user.admin?
      flash[:error] = "You are not authorized to do that."
      redirect_to(root_path)
    end
  end
end