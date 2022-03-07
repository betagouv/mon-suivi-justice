class ApiController < ActionController::API
  include ActionController::HttpAuthentication::Basic::ControllerMethods
  http_basic_authenticate_with name: ENV['HTTP_BASIC_AUTH_USER'],
                               password: ENV['HTTP_BASIC_AUTH_PSWD']

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  private

  def record_not_found
    render json: { error: 'Not found' }, status: :not_found
  end
end
