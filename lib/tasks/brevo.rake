
namespace :brevo do
  desc "Enrich users data in Brevo service"
  task enrich_users: :environment do
    adapter = BrevoAdapter.new

    User.find_each do |user|
      adapter.update_user_contact(user)
    end
  end
end
