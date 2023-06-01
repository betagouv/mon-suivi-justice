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
    old_place = transfert_place.old_place
    new_place = transfert_place.new_place
    # Duplicate agendas from old place to new place
    # Move slots from old place to new place after transfer date
    old_place.agendas.each do |agenda|
      new_place_agenda = agenda.dup
      new_place_agenda.place = new_place
      new_place_agenda.name = "#{agenda.name} transféré - #{I18n.l(transfert_place.date)}"
      new_place_agenda.appointment_types.concat(agenda.appointment_types)

      next unless new_place_agenda.save

      @transfert_successes.push("Agenda #{agenda.name} transféré avec succès")

      transfert_slots(agenda, new_place_agenda, transfert_place.date)
    end
  end

  def transfert_slots(_old_agenda, _new_agenda, date)
    agenda.slots.where('date >= ?', date).update_all(agenda_id: new_place_agenda.id)

    agenda.slot_types.each do |slot_type|
      new_slot_type = slot_type.dup
      new_slot_type.agenda = new_place_agenda
      new_slot_type.save
    end

    @transfert_successes.push("Les créneaux de l'agenda #{agenda.name} ont été transférés avec succès")
  end
end
