class UserMailer < ApplicationMailer
  default from: 'system@mon-suivi-justice.beta.gouv.fr'

  def notify_mutation(user, old_organization)
    @user = user
    @old_organization = old_organization
    mail(to: @user.email, subject: 'Notification de Mutation')
  end

  def notify_admins_of_mutation(user, old_organization)
    @admins = old_organization.users.where(role: 'admin')
    @user = user
    mail(to: @admins.map(&:email), subject: 'Un utilisateur a été muté')
  end
end
