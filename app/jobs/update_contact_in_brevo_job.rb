class UpdateContactInBrevoJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find(user_id)
    BrevoAdapter.new.update_user_contact(user)
  end
end
