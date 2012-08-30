class OrganizationsController < ApplicationController

  before_filter :require_admin, :only => [ :index, :change_status ]

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
      flash[:notice] = t("pending_approval_message")
    else
      flash[:error] = t("creation_failed")
      render :new
    end
	end

  def index
    @organizations = Organization.all
  end

  def change_status
    organization = Organization.find(params[:organization_id])
    organization.status = params[:status]
    if organization.save
      if organization.approved?
        UserMailer.approval_mail(organization.users.first).deliver
      end
      if organization.rejected?
        UserMailer.rejection_mail(organization.users.first, params[:rejection_message].presence).deliver
      end
    end
    flash[:notice] = t "status_changed", :organization_name => organization.name, :status => organization.status
    redirect_to organizations_path
  end

  private

  def require_admin
    if !has_signed_in_user?
      flash[:error] = t "please_login"
      redirect_to(login_path)
    elsif !current_user.admin?
      flash[:error] = t "not_authorized"
      redirect_to(root_path)
    end
  end
end