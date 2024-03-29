class DeleteContactInBrevoJob < ApplicationJob
  queue_as :default

  def perform(user_email, admin = nil)
    adapter = BrevoAdapter.new

    begin
      adapter.delete_user_contact(user_email)
    rescue StandardError => e
      AdminMailer.with(admin:, user_email:, error: e).brevo_sync_failure.deliver_now
    end
  end
end
