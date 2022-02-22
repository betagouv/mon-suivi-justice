class ApiController < ActionController::API

  class ActionForbidden < StandardError; end

  include ActionController::HttpAuthentication::Basic::ControllerMethods
  http_basic_authenticate_with name: ENV["HTTP_BASIC_AUTH_USER"],
    password: ENV["HTTP_BASIC_AUTH_PSWD"]

  rescue_from StandardError, with: :server_failed
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  private

  def record_not_found
    render json: {error: "Not found"}, status: :not_found
  end

  def server_failed
    render json: {error: "Internal server error"}, status: :internal_server_error
  end
end
