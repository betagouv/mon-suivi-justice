
class UpdateContactInBrevoJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find(user_id)
    adapter = BrevoAdapter.new

    begin
      adapter.update_user_contact(user)
    rescue => e
      # Send email to admins about the failure
      AdminMailer.brevo_sync_failure(user, e.message).deliver_now
    end
  end
end
