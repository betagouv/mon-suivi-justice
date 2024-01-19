class UserMailer < ApplicationMailer
  default from: 'system@mon-suivi-justice.beta.gouv.fr'

  def notify_mutation(user)
    @user = user
    mail(to: @user.email, subject: 'Notification de mutation dans Mon Suivi Justice')
  end

  def notify_local_admins_of_mutation(user, old_organization)
    @admins = old_organization.users_local_admin
    @admins = old_organization.headquarter&.users_local_admin if @admins.empty?
    return if @admins.empty?

    @user = user
    mail(to: @admins.map(&:email), subject: "L'agent #{@user.name} a été muté dans Mon Suivi Justice")
  end
end
