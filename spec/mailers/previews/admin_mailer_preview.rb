# Preview all emails at http://localhost:3001/rails/mailers/admin_mailer
class AdminMailerPreview < ActionMailer::Preview
  def warn_link_mobility_for_misrouted_notifications
    phones = [
      '+33612345678',
      '+33687654321',
      '+33699999999'
    ]

    AdminMailer.with(
      phones: phones
    ).warn_link_mobility_for_misrouted_notifications
  end
end
