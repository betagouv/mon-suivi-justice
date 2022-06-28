class ApiController < ActionController::API
  include ActionController::HttpAuthentication::Basic::ControllerMethods
  http_basic_authenticate_with name: ENV.fetch('HTTP_BASIC_AUTH_USER', nil),
                               password: ENV.fetch('HTTP_BASIC_AUTH_PSWD', nil)

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  private

  def record_not_found
    render json: { error: 'Not found' }, status: :not_found
  end
end
