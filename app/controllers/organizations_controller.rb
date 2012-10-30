class OrganizationsController < ApplicationController
  load_and_authorize_resource :except => :create

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
      flash[:notice] = t("successful_create_message")
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
    UserMailer.deactivation_mail(organization.cso_admin, organization.default_locale, params[:deactivate_message]).deliver
    flash[:notice] = t "status_changed", :organization_name => organization.name, :status => organization.status
    redirect_to organizations_path
  end
end
