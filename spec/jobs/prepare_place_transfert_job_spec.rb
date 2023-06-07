require 'rails_helper'

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
      create(:place, agendas: [old_agenda], appointment_types: [appointment_type], organization: organization)
    end
    let(:new_place) { create(:place, organization: organization) }
    let(:place_transfert) { create(:place_transfert, old_place: old_place, new_place: new_place, date: Date.tomorrow) }

    before do
      @after_slot = build(:slot, agenda: old_agenda, date: Date.today + 2.days, appointment_type: appointment_type)
      @after_slot.save(validate: false)
      @before_slot = create(:slot, agenda: old_agenda, date: Date.today, appointment_type: appointment_type)
      PreparePlaceTransfertJob.new.perform(place_transfert.id, user)
    end

    it('transfert slot after to new place') do
      expect(@after_slot.reload.agenda.place).to eq(new_place)
    end

    it('should keep slot before') do
      expect(@before_slot.reload.agenda.place).to eq(old_place)
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
  end
end
