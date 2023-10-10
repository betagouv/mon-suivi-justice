class UpdateContactInBrevoJob < ApplicationJob
  queue_as :default

  def perform(user_id, admin = nil)
    user = User.find(user_id)
    adapter = BrevoAdapter.new

    begin
      adapter.update_user_contact(user)
    rescue StandardError => e
      AdminMailer.with(admin:, user:, error: e).brevo_sync_failure.deliver_now
    end
  end
end
