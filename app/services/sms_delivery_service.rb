class SmsDeliveryService
  attr_reader :notification

  # Gérer failed summon et reschedule notif dans le service qui manage les fails
  # Gérer tous les codes d'erreur de l'API de SMS (renvoyer le code via l'adapteur ou si on doit stopper + relancher + message)
  # Raise pour les notifications created en entrée
  # Ne pas envoyer de notifications aux probationnaires qui refusent de donner leur numéro
  # Catcher les erreurs à ne pas raise et relancer et relancer le SMS manuellement 5 secondes plus tard en incrémentant le fail count
  # Raise les notifications à ne plus renvoyer
  # Raise en entrée pour les notifications avec plus de 5 fails
  # Catcher les 2 types ci-dessus et les passer à failed
  # Pour toutes les autres erreurs, incrémenter le fail et raise normalement pour retenter automatiquement
  # Comprendre pourquoi certains SMS sont reschedule
  # Envoyer toutes les 48h un mail à LinkMobility avec les numéros ayant des problèmes de routing

  def initialize(notification)
    @notification = notification
  end

  def send_sms
    return unless sms_can_be_send?

    response = LinkMobilityAdapter.new(notification).send_sms

    update_state_from_response(response)
  end

  private

  def sms_can_be_send?
    return false unless notification.programmed? || notification.created?

    unless notification.convict.can_receive_sms?
      notification.mark_as_unsent!
      return false
    end

    true
  end

  def update_state_from_response(response)
    notification.transaction do
      notification.update!(external_id: response.external_id) if response.external_id.present?

      if response.success
        mark_as_sent
      else
        manage_failure
      end
    end
  end

  def mark_as_sent
    attempts = 0
    begin
      attempts += 1
      notification.reload
      notification.mark_as_sent!
    rescue StandardError => e
      raise e unless attempts < 5

      sleep 0.5
      retry
    end
  end

  def manage_failure
    if notification.failed_count >= 5
      notification.mark_as_failed!
    else
      notification.increment!(:failed_count)
      SmsDeliveryJob.set(wait: 5.minutes).perform_later(notification.id)
    end
  end
end
