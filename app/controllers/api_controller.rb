class ApiController < ActionController::API
  include ActionController::HttpAuthentication::Basic::ControllerMethods
  http_basic_authenticate_with name: ENV["HTTP_BASIC_AUTH_USER"],
    password: ENV["HTTP_BASIC_AUTH_PSWD"]
end
