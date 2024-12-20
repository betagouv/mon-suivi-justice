class AdminMailer < ApplicationMailer
  default from: 'system@mon-suivi-justice.beta.gouv.fr'

  # rubocop:disable Metrics/AbcSize
  def appi_import_report
    @user = params[:user]
    @target_organizations = params[:target_organizations]
    @import_successes = params[:import_successes]
    @import_errors = params[:import_errors]
    @import_update_successes = params[:import_update_successes]
    @import_update_failures = params[:import_update_failures]
    @calculated_organizations_names = params[:calculated_organizations_names]
    @csv_errors = params[:csv_errors]
    mail(to: @user.email, subject: 'Rapport import APPI')
  end
  # rubocop:enable Metrics/AbcSize

  def srj_import_report
    @user = params[:user]
    @import_successes = params[:import_successes]
    @import_errors = params[:import_errors]
    @csv_errors = params[:csv_errors]
    mail(to: @user.email, subject: 'Rapport import SRJ')
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
    @user_email = params[:user_email]
    @error = params[:error]

    mail(to: @admin ? @admin.email : 'support@mon-suivi-justice.beta.gouv.fr',
         subject: "Echec de synchronisation avec Brevo pour l'agent #{@user_email}")
  end

  def notifications_problems(stucked_ids)
    @stucked_ids = stucked_ids
    mail(to: devs,
         subject: 'Notifications remises dans la queue')
  end

  def warn_link_mobility_for_misrouted_notifications
    @phones = params[:phones]
    mail(to: 'support.fr@linkmobility.com',
         cc: devs,
         subject: 'Mon Suivi Justice - Liste des numéros non routés')
  end

  private

  def devs
    ENV.fetch('DEVS').split(',')
  end
end
