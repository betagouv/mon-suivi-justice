class ErrorsController < ApplicationController
  def not_found
    render status: 404
  end

  def internal_server_error
    render status: 500
  end

  def unprocessable_entity
    render status: 422
  end

  private

  def skip_pundit?
    true
  end
end
