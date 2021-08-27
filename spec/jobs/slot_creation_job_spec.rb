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
    let(:tested_method) { SlotCreationJob.new.perform }

    before do
      allow(Time).to receive(:now).and_return frozen_time
      allow(SlotFactory).to receive(:new)
      tested_method
    end

    it 'instantiates Slot factory' do
      expect(SlotFactory).to have_received(:new).once
    end
    it 'queues itself for next week' do
      expect(SlotCreationJob).to have_been_enqueued.once.at(1.week.since)
    end
  end
end
