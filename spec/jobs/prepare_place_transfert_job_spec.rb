require 'rails_helper'
require './spec/support/notification_helpers'

RSpec.configure do |c|
  c.include NotificationHelpers
end

RSpec.describe PreparePlaceTransfertJob, type: :job do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, organization:) }
  describe '#perform_later' do
    let(:tested_method) { PreparePlaceTransfertJob.perform_later(12, user) }

    it 'queues the job' do
      tested_method
      expect(PreparePlaceTransfertJob).to have_been_enqueued.once
    end
  end

  describe '#perform' do
    let(:appointment_type) { create(:appointment_type) }
    let(:old_agenda) { create(:agenda) }
    let(:slot_type) { create(:slot_type, appointment_type:, agenda: old_agenda) }
    let(:old_place) do
      create(:place, agendas: [old_agenda], appointment_types: [appointment_type], organization:,
                     name: 'SPIP 45 - Montargis', adress: "111, piazza Mont-d'Est, 93160, Noisy-le-Grand",
                     phone: '0102030405', contact_email: 'mont@rgis.con',
                     preparation_link: 'https://mon-suivi-justice.beta.gouv.fr/preparer_spip_loiret_montargis')
    end
    let(:new_place) do
      np = build(:place, organization:, name: 'Nouveau SPIP 45 - Montargis',
                         adress: '8 av Adolphe Cochery, 45200 Montargis',
                         phone: '0238858585', contact_email: 'new-mont@rgis.con',
                         preparation_link: 'https://mon-suivi-justice.beta.gouv.fr/preparer_new_spip_loiret_montargis')
      np.save(validate: false)
      np
    end
    let(:place_transfert) do
      create(:place_transfert, old_place:, new_place:, date: next_valid_day(date: Date.tomorrow))
    end
    let!(:before_slot) { create(:slot, agenda: old_agenda, date: next_valid_day(date: Date.today), appointment_type:) }

    let!(:after_slot) do
      slot = build(:slot, agenda: old_agenda, date: next_valid_day(date: Date.today + 2.days), appointment_type:,
                          slot_type: nil)
      slot.save(validate: false)
      slot
    end

    let!(:after_slot_from_type) do
      slot = build(:slot, agenda: old_agenda, date: next_valid_day(date: Date.today + 2.days), appointment_type:,
                          slot_type:)
      slot.save(validate: false)
      slot
    end

    let!(:after_appointment) { create(:appointment, slot: after_slot) }
    let!(:before_appointment) { create(:appointment, slot: before_slot) }
    let!(:after_notication) do
      create(:notification, appointment: after_appointment,
                            content: convocation_template(old_place))
    end
    let!(:before_notication) do
      create(:notification, appointment: before_appointment,
                            content: convocation_template(old_place))
    end

    before do
      PreparePlaceTransfertJob.new.perform(place_transfert.id, user)
    end

    it('transfert slot after to new place') do
      expect(after_slot.reload.place).to eq(new_place)
    end

    it('should keep slot before') do
      expect(before_slot.reload.agenda.place).to eq(old_place)
    end

    it('should create agenda for new place') do
      expect(new_place.agendas.count).to eq(1)
    end

    it('should copy old place appointment types to new place') do
      expect(new_place.reload.appointment_types).to match_array(old_place.appointment_types)
    end

    it('should copy old place slot types to new place') do
      new_agenda = new_place.agendas.first
      new_recurring_slot = new_agenda.slot_types.first

      old_agenda = old_place.agendas.first
      old_recuring_slot = old_agenda.slot_types.first

      expect(new_recurring_slot.duration).to eq(old_recuring_slot.duration)
      expect(new_recurring_slot.capacity).to eq(old_recuring_slot.capacity)
      expect(new_recurring_slot.starting_time).to eq(old_recuring_slot.starting_time)
      expect(new_recurring_slot.week_day).to eq(old_recuring_slot.week_day)
      expect(new_recurring_slot.appointment_type).to eq(old_recuring_slot.appointment_type)
    end

    it('should update slots, slot_type_id') do
      new_agenda = new_place.agendas.first
      new_recurring_slot = new_agenda.slot_types.first

      expect(after_slot_from_type.reload.slot_type_id).to eq(new_recurring_slot.id)
      expect(after_slot_from_type.place).to eq(new_place)
    end

    it('should update notification text') do
      expect(before_notication.reload.content).to eq(convocation_template(old_place))
      expect(after_notication.reload.content).to eq(convocation_template(new_place))
    end
  end
end
