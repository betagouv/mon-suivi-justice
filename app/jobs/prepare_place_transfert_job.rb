class PreparePlaceTransfertJob < ApplicationJob
  def perform(place_transfert_id, user)
    @transfert_errors = []
    @transfert_successes = []
    place_transfert = PlaceTransfert.find(place_transfert_id)
    ActiveRecord::Base.transaction do
      start_transfert(place_transfert)
    end
  rescue StandardError => e
    @transfert_errors.push("Erreur : #{e.message}")
  ensure
    AdminMailer.with(user:, transfert: place_transfert, transfert_errors: @transfert_errors,
                     transfert_successes: @transfert_successes).prepare_place_transfert.deliver_later
  end

  def start_transfert(place_transfert)
    new_place = place_transfert.new_place
    old_place = place_transfert.old_place
    puts "Start transfering old_place: #{old_place} to new_place: #{new_place}"
    new_place.update!(appointment_types: old_place.appointment_types)
    transfert_agendas(place_transfert)
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

    new_place_agenda.update!(place: place_transfert.new_place,
                             name: "#{old_place_agenda.name} transféré - #{I18n.l(place_transfert.date)}")

    @transfert_successes.push("Agenda #{old_place_agenda.name} transféré avec succès")

    transfert_slots(old_place_agenda, new_place_agenda, place_transfert.date)
  end

  def transfert_slots(old_place_agenda, new_place_agenda, date)
    # transfert slots after transfert date from old place to new place
    old_slots = old_place_agenda
                .slots.where('date >= ?', date)
                .where(slot_type: nil)

    old_slots.update_all(agenda_id: new_place_agenda.id)
    old_place_agenda.slot_types.each do |slot_type|
      transfert_slot_type(slot_type, new_place_agenda, date)
    end

    update_notifications_text(old_place_agenda, new_place_agenda)

    @transfert_successes.push("Les créneaux de l'agenda #{old_place_agenda.name} ont été transférés avec succès")
  end

  def transfert_slot_type(slot_type, new_place_agenda, date)
    new_slot_type = slot_type.dup
    new_slot_type.update!(agenda: new_place_agenda)
    slot_type.slots
             .where('date >= ?', date)
             .update_all(slot_type_id: new_slot_type.id, agenda_id: new_place_agenda.id)
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
        notification.update!(content:)
      end
    end
  end

  def modify_notif_content(old_place, new_place, notification)
    attributes = %i[name adress contact_email preparation_link]

    modified_content = notification.content
    attributes.each do |attr|
      if old_place.send(attr) && new_place.send(attr)
        modified_content = modified_content.gsub(old_place.send(attr), new_place.send(attr))
      end
    end

    if old_place.display_phone && new_place.display_phone
      modified_content = modified_content.gsub(old_place.display_phone(spaces: false),
                                               new_place.display_phone(spaces: false))
      modified_content = modified_content.gsub(old_place.display_phone(spaces: true),
                                               new_place.display_phone(spaces: false))
    end

    modified_content
  end
end
