namespace :brevo do
  desc 'Enrich users data in Brevo service'
  task enrich_users: :environment do
    adapter = BrevoAdapter.new

    User.find_each do |user|
      if adapter.user_exists_in_brevo?(user.email)
        puts "Updating #{user.email} in Brevo"
        adapter.update_user_contact(user)
      else
        puts "Creating #{user.email} in Brevo"
        adapter.create_contact_for_user(user)
      end
    end
  end
end
