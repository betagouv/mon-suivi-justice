class CreateContactInBrevoJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find(user_id)
    adapter = BrevoAdapter.new

    begin
      adapter.create_contact_for_user(user)
    rescue StandardError => e
      AdminMailer.brevo_sync_failure(user, e.message).deliver_now
    end
  end
end
