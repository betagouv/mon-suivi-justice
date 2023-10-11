namespace :brevo do
  desc 'Enrich users data in Brevo service'
  task enrich_users: :environment do
    adapter = BrevoAdapter.new

    User.find_each do |user|
      if adapter.user_exists_in_brevo?(user.email)
        adapter.update_user_contact(user)
      else
        adapter.create_user_in_brevo(user)
      end
    end
  end
end
