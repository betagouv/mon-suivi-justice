class CreateContactInBrevoJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find(user_id)
    BrevoAdapter.new.create_contact_for_user(user)
  end
end
