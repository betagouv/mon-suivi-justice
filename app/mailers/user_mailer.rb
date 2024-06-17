class UserMailer < ApplicationMailer
  default from: 'system@mon-suivi-justice.beta.gouv.fr'

  def notify_mutation(user)
    @user = user
    mail(to: @user.email, subject: 'Notification de mutation dans Mon Suivi Justice')
  end

  def notify_local_admins_of_mutation(user, old_organization)
    @admins = old_organization.local_admins
    @admins = old_organization.headquarter&.local_admins if @admins.blank?
    return if @admins.blank?

    @user = user
    mail(to: @admins.map(&:email), subject: "L'agent #{@user.name} a été muté dans Mon Suivi Justice")
  end

  def notify_local_admins_of_divestment(organization)
    @admins = organization.local_admins
    return if @admins.blank?

    mail(to: @admins.map(&:email), subject: 'Vous avez des demandes de dessaisissement en attente')
  end

  def divestment_accepted
    divestment = params[:divestment]
    user = divestment.user
    @convict = divestment.convict
    mail(to: [user.email], subject: 'Votre demande de dessaisissement a été acceptée')
  end

  def divestment_refused
    @divestment = params[:divestment]
    @organization_divestment = params[:organization_divestment]
    @comment = @organization_divestment.comment
    @current_user = params[:current_user]
    @convict = @divestment.convict
    user = @divestment.user
    mail(to: [user.email], subject: 'Votre demande de dessaisissement a été refusée')
  end
end
