require 'rails_helper'
require './spec/support/notification_helpers'

RSpec.configure do |c|
  c.include NotificationHelpers
end

RSpec.describe TransfertPlacesJob, type: :job do
  let!(:organization) { create(:organization) }
  describe '#perform_later' do
    let(:tested_method) { TransfertPlacesJob.perform_later }

    it 'queues the job' do
      tested_method
      expect(TransfertPlacesJob).to have_been_enqueued.once
    end
  end

  describe '#perform' do
    let(:appointment_type) { create(:appointment_type) }
    let(:old_agenda) { create(:agenda) }
    let(:old_place) do
      create(:place, agendas: [old_agenda], appointment_types: [appointment_type], organization: organization)
    end
    let!(:place_transfert) do
      pt = build(:place_transfert, old_place: old_place, date: Date.today)
      pt.save(validate: false)
      pt
    end
    let!(:place_transfert_later) { create(:place_transfert, date: Date.tomorrow) }
    let!(:before_slot_type) { create(:slot_type, agenda: old_agenda, appointment_type: appointment_type) }

    before do
      TransfertPlacesJob.new.perform
    end

    it('should discard old place') do
      expect(old_place.reload.discarded?).to eq(true)
    end

    it('should discard old place agendas') do
      expect(old_agenda.reload.discarded?).to eq(true)
    end

    it('should discard old place agendas slot_types') do
      expect(before_slot_type.reload.discarded?).to eq(true)
    end

    it('should change the status of the place_transfert') do
      expect(place_transfert.reload.status).to eq('transfert_done')
    end

    it('should not apply to later place_transfert') do
      expect(place_transfert_later.reload.status).to eq('transfert_pending')
    end
  end
end
