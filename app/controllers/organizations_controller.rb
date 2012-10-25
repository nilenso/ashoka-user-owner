class OrganizationsController < ApplicationController

  before_filter :require_admin, :only => [ :index, :activate, :deactivate ]

  def new
    @organization = Organization.new
    @organization.users << User.new
  end

  def create
    @organization = Organization.build(params[:organization][:name], 
                                       params[:organization][:users])

    @organization.default_locale = I18n.locale.to_s

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

  def activate
    organization = Organization.find(params[:organization_id])
    organization.activate
    UserMailer.activation_mail(organization.cso_admin, organization.default_locale).deliver
    flash[:notice] = t "status_changed", :organization_name => organization.name, :status => organization.status
    redirect_to organizations_path
  end

  def deactivate
    organization = Organization.find(params[:organization_id])
    organization.deactivate
    UserMailer.deactivation_mail(organization.cso_admin, organization.default_locale, params[:rejection_message]).deliver
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
