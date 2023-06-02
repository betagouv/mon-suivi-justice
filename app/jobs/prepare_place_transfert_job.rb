class PreparePlaceTransfertJob < ApplicationJob
  def perform(transfert_place)
    @transfert_errors = []
    @transfert_successes = []
    puts "Start tranfering old_place: #{old_place} to new_place: #{new_place}"
    transfert_agendas(transfert_place)
  rescue StandardError => e
    @transfert_errors.push("Erreur : #{e.message}")
  ensure
    AdminMailer.with(user: user, transfert: transfert_place, transfert_errors: @import_errors,
                     transfert_successes: @import_successes).prepare_place_transfert.deliver_later
  end

  def transfert_agendas(transfert_place)
    # Duplicate agendas from old place to new place
    # Move slots from old place to new place after transfer date
    transfert_place.old_place.agendas.each do |agenda|
      transfert_agenda(agenda, transfert_place)
    end
  end

  def transfert_agenda(old_place_agenda, transfert_place)
    new_place_agenda = old_place_agenda.dup
    new_place_agenda.place = transfert_place.new_place
    new_place_agenda.name = "#{old_place_agenda.name} transféré - #{I18n.l(transfert_place.date)}"
    new_place_agenda.appointment_types.concat(old_place_agenda.appointment_types)

    next unless new_place_agenda.save

    @transfert_successes.push("Agenda #{old_place_agenda.name} transféré avec succès")

    transfert_slots(agenda, new_place_agenda, transfert_place.date)
  end

  def transfert_slots(old_place_agenda, new_place_agenda, date)
    old_slots = old_place_agenda.slots.where('date >= ?', date)
    old_slots.update_all(agenda_id: new_place_agenda.id)

    old_place_agenda.slot_types.each do |slot_type|
      new_slot_type = slot_type.dup
      new_slot_type.agenda = new_place_agenda
      new_slot_type.save
    end

    update_notifications_text(old_place_agenda, new_place_agenda, old_slots)

    @transfert_successes.push("Les créneaux de l'agenda #{agenda.name} ont été transférés avec succès")
  end

  def update_notifications_text(old_place_agenda, new_place_agenda, old_slots)
    old_place = old_place_agenda.place
    new_place = new_place_agenda.place

    old_slots.each do |slot|
      transfert_appointment_notifications(old_place, new_place, slot)
    end
  end

  def transfert_appointment_notifications(old_place, new_place, slot)
    slot.appointments.each do |appointment|
      appointment.notifications.where(state: %w[programmed created]).update_all(
        content: ActiveRecord::Base.connection.quote_string(
          notification.content.gsub(old_place.name, new_place.name).gsub(old_place.address, new_place.address)
        )
      )
    end
  end
end
