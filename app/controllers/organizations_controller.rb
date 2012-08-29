class OrganizationsController < ApplicationController
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
end