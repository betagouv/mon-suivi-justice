class PreparePlaceTransfertJob < ApplicationJob
  def perform(place_transfert_id, user)
    @transfert_errors = []
    @transfert_successes = []
    place_transfert = PlaceTransfert.find(place_transfert_id)

    start_transfert(place_transfert)
  rescue StandardError => e
    @transfert_errors.push("Erreur : #{e.message}")
  ensure
    AdminMailer.with(user: user, transfert: place_transfert, transfert_errors: @transfert_errors,
                     transfert_successes: @transfert_successes).prepare_place_transfert.deliver_later
  end

  def start_transfert(place_transfert)
    new_place = place_transfert.new_place
    old_place = place_transfert.old_place
    puts "Start transfering old_place: #{old_place} to new_place: #{new_place}"
    new_place.appointment_types.concat(old_place.appointment_types)

    transfert_agendas(place_transfert) if new_place.save
  end

  def transfert_agendas(place_transfert)
    # Duplicate agendas from old place to new place
    # Move slots from old place to new place after transfer date
    place_transfert.old_place.agendas.each do |agenda|
      transfert_agenda(agenda, place_transfert)
    end
  end

  def transfert_agenda(old_place_agenda, place_transfert)
    new_place_agenda = old_place_agenda.dup
    new_place_agenda.place = place_transfert.new_place
    new_place_agenda.name = "#{old_place_agenda.name} transféré - #{I18n.l(place_transfert.date)}"

    return unless new_place_agenda.save

    @transfert_successes.push("Agenda #{old_place_agenda.name} transféré avec succès")

    transfert_slots(old_place_agenda, new_place_agenda, place_transfert.date)
  end

  def transfert_slots(old_place_agenda, new_place_agenda, date)
    old_slots = old_place_agenda.slots.where('date >= ?', date)
    old_slots.update_all(agenda_id: new_place_agenda.id)
    old_place_agenda.slot_types.each do |slot_type|
      new_slot_type = slot_type.dup
      new_slot_type.agenda = new_place_agenda
      new_slot_type.save
    end

    update_notifications_text(old_place_agenda, new_place_agenda)

    @transfert_successes.push("Les créneaux de l'agenda #{old_place_agenda.name} ont été transférés avec succès")
  end

  def update_notifications_text(old_place_agenda, new_place_agenda)
    old_place = old_place_agenda.place
    new_place = new_place_agenda.place

    new_place_agenda.slots.each do |slot|
      transfert_appointment_notifications(old_place, new_place, slot)
    end
  end

  def transfert_appointment_notifications(old_place, new_place, slot)
    slot.appointments.each do |appointment|
      appointment.notifications.where(state: %w[programmed created]).each do |notification|
        content = modify_notif_content(old_place, new_place, notification)
        notification.update(content: content)
      end
    end
  end

  def modify_notif_content(old_place, new_place, notification)
    notification.content.gsub(old_place.name, new_place.name)
                .gsub(old_place.adress, new_place.adress)
                .gsub(old_place.display_phone, new_place.display_phone)
                .gsub(old_place.contact_email, new_place.contact_email)
                .gsub(old_place.preparation_link, new_place.preparation_link)
  end
end
