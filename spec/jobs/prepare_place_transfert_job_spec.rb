require 'rails_helper'
require './spec/support/notification_helpers'

RSpec.configure do |c|
  c.include NotificationHelpers
end

RSpec.describe PreparePlaceTransfertJob, type: :job do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, organization: organization) }
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
    let(:old_place) do
      create(:place, agendas: [old_agenda], appointment_types: [appointment_type], organization: organization,
                     name: 'SPIP 45 - Montargis', adress: "111, piazza Mont-d'Est, 93160, Noisy-le-Grand")
    end
    let(:new_place) do
      create(:place, organization: organization, name: 'Nouveau SPIP 45 - Montargis',
                     adress: '8 av Adolphe Cochery, 45200 Montargis')
    end
    let(:place_transfert) { create(:place_transfert, old_place: old_place, new_place: new_place, date: Date.tomorrow) }
    let!(:before_slot) { create(:slot, agenda: old_agenda, date: Date.today, appointment_type: appointment_type) }
    let!(:after_slot) do
      slot = build(:slot, agenda: old_agenda, date: Date.today + 2.days, appointment_type: appointment_type)
      slot.save(validate: false)
      slot
    end

    let!(:after_appointment) { create(:appointment, slot: after_slot) }
    let!(:before_appointment) { create(:appointment, slot: before_slot) }
    let!(:after_notication) do
      create(:notification, appointment: after_appointment,
                            content: convocation_template(old_place.name, old_place.adress))
    end
    let!(:before_notication) do
      create(:notification, appointment: before_appointment,
                            content: convocation_template(old_place.name, old_place.adress))
    end

    before do
      PreparePlaceTransfertJob.new.perform(place_transfert.id, user)
    end

    it('transfert slot after to new place') do
      expect(after_slot.reload.agenda.place).to eq(new_place)
    end

    it('should keep slot before') do
      expect(before_slot.reload.agenda.place).to eq(old_place)
    end

    it('should create agenda for new place') do
      expect(new_place.agendas.count).to eq(1)
    end

    it('should copy old place appointment types to new place') do
      expect(new_place.appointment_types).to match_array(old_place.appointment_types)
    end

    it('should copy old place slot types to new place') do
      expect(new_place.agendas.first.slot_types).to match_array(old_place.agendas.first.slot_types)
    end

    it('should update notification text') do
      expect(before_notication.reload.content).to eq(convocation_template(old_place.name, old_place.adress))
      expect(after_notication.reload.content).to eq(convocation_template(new_place.name, new_place.adress))
    end
  end
end
