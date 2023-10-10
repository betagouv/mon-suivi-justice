class AdminMailer < ApplicationMailer
  default from: 'system@mon-suivi-justice.beta.gouv.fr'

  def appi_import_report
    @user = params[:user]
    @organizations = params[:organizations]
    @import_successes = params[:import_successes]
    @import_errors = params[:import_errors]
    @csv_errors = params[:csv_errors]
    mail(to: @user.email, subject: 'Rapport import APPI')
  end

  def srj_import_report
    @user = params[:user]
    @import_successes = params[:import_successes]
    @import_errors = params[:import_errors]
    @csv_errors = params[:csv_errors]
    mail(to: @user.email, subject: 'Rapport import SRJ')
  end

  def convict_migration_report
    @convict_migration_success = params[:convict_migration_success]
    @convict_migration_errors = params[:convict_migration_errors]
    mail(to: 'matthieu.faugere@beta.gouv.fr', subject: 'Rapport migration des convicts')
    mail(to: 'charles.marcoin@beta.gouv.fr', subject: 'Rapport migration des convicts')
  end

  def link_convict_from_organizations_source
    @user = params[:user]
    @organization = params[:organization]
    @import_successes = params[:import_successes]
    @import_errors = params[:import_errors]
    @sources = params[:sources]
    mail(to: @user.email, subject: "Rapport d'import de convict dans #{@organization.name}")
  end

  def prepare_place_transfert
    @user = params[:user]
    @transfert_successes = params[:transfert_successes]
    @transfert_errors = params[:transfert_errors]
    @old_place = params[:transfert].old_place.name
    @new_place = params[:transfert].new_place.name

    mail(to: @user.email, subject: "Rapport d'import de préparation de transfert de #{@old_place} vers #{@new_place}")
  end

  def user_alert_delivery_report
    @user = params[:user]
    @content = params[:content]
    @organization = params[:organization]
    @errors = params[:errors]
    @number_of_recipients = params[:number_of_recipients]
    @role = params[:role]
    mail(to: @user.email, subject: "Rapport d'import de création d'alerte utilisateur")
  end
    
  def brevo_sync_failure
    @admin = params[:admin]
    @user = params[:user]
    @error = params[:error]

    mail(to: @admin ? @admin.email : 'charles.marcoin@beta.gouv.fr',
         subject: "Echec de synchronisation avec Brevo pour l'agent #{@user.email}")
  end
end
