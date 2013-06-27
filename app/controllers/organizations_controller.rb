class OrganizationsController < ApplicationController
  load_and_authorize_resource :except => :create
  require_password_confirmation_for :destroy

  def new
    @organization = Organization.new.decorate
    @organization.users.new
  end

  def create
    @organization = Organization.build(params[:organization],
                                       params[:organization][:users])

    @organization.default_locale = I18n.locale.to_s

    if @organization.save
      redirect_to root_path
      flash[:notice] = t("successful_create_message")
    else
      @organization = @organization.decorate
      flash[:error] = t("creation_failed")
      render :new
    end
  end

  def index
  end

  def show
    @organization = Organization.find_by_id(params[:id])
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
    UserMailer.deactivation_mail(organization.cso_admin, organization.default_locale, params[:deactivate_message]).deliver
    flash[:notice] = t "status_changed", :organization_name => organization.name, :status => organization.status
    redirect_to organizations_path
  end

  def destroy
    organization = Organization.find(params[:id])
    organization.users.each(&:soft_delete)
    organization.soft_delete
    reset_session
    flash[:notice] = I18n.t("organizations.destroy.organization_to_be_deleted")
    redirect_to root_path
  end
end
