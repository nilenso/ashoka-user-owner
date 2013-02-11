module Api
  module V1
    class OrganizationsController < ActionController::Base
      skip_authorize_resource
      doorkeeper_for :all
      respond_to :json

      def index
        organizations = Organization.active_organizations
        respond_with organizations.to_json(:only => [:id, :name])
      end

      def validate_orgs
        org_ids = JSON.parse(params[:org_ids])
        respond_with Organization.valid_ids?(org_ids).to_json
      end
    end
  end
end
