class Api::V1::DeletedOrganizationsController < ApplicationController
  def index
    render :json => Organization.unscoped.deleted.pluck("id")
  end
end
