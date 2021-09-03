require 'rails_helper'

RSpec.describe SlotCreationJob, type: :job do
  describe '#perform_later' do
    let(:tested_method) { SlotCreationJob.perform_later }

    it 'queues the job' do
      tested_method
      expect(SlotCreationJob).to have_been_enqueued.once
    end
  end

  describe '#perform' do
    let(:frozen_time) { Time.zone.parse '2021-05-03' }
    before do
      allow(Time).to receive(:now).and_return frozen_time
      allow(SlotFactory).to receive(:perform)
    end

    context 'with auto-relaunch for the job' do
      before { SlotCreationJob.new.perform }

      it 'instantiates Slot factory' do
        expect(SlotFactory).to have_received(:perform).once
      end
      it 'queues itself for next week' do
        expect(SlotCreationJob).to have_been_enqueued.once.at(1.week.since)
      end
    end

    context 'with one shot option' do
      before { SlotCreationJob.new.perform oneshot: true }

      it 'instantiates Slot factory' do
        expect(SlotFactory).to have_received(:perform).once
      end
      it 'does not queues itself for next week' do
        expect(SlotCreationJob).not_to have_been_enqueued
      end
    end
  end
end
