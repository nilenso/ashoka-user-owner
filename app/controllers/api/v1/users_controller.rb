module Api
  module V1
    class UsersController < ActionController::Base
      doorkeeper_for :all
      respond_to :json

      def show
        respond_with current_user.to_json(:except => :password_digest)
      end

    private

      def current_user
        @current_user ||= User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
      end
    end
  end
end
