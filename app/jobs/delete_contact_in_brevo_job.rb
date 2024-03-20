class DeleteContactInBrevoJob < ApplicationJob
  queue_as :default

  def perform(user_id, admin = nil)
    adapter = BrevoAdapter.new
    user = User.find(user_id)

    begin
      adapter.delete_user_contact(user.email)
    rescue StandardError => e
      AdminMailer.with(admin:, user_id:, error: e).brevo_sync_failure.deliver_now
    end
  end
end
