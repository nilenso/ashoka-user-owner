
module Api
  module V1
    class UsersController < ActionController::Base
      doorkeeper_for :all
      load_and_authorize_resource :user, :parent => false
      respond_to :json

      def show
        respond_with current_user.to_json(:except => :password_digest)
      end

      def index
        user_ids = params[:user_ids]
        organization = Organization.find(params[:organization_id])
        @users = @users.select! { |user| user_ids.include?(user.id.to_s) } if user_ids
        respond_with @users.to_json(:only => [:id, :name])
      end

      private

      def current_user
        @current_user ||= User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
      end
    end
  end
end
