class DeleteContactInBrevoJob < ApplicationJob
  queue_as :default

  def perform(user_email)
    BrevoAdapter.new.delete_user_contact(user_email)
  end
end
