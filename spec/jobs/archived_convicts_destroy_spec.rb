require 'rails_helper'

RSpec.describe ArchivedConvictsDestroy, type: :job do
  describe '#perform_later' do
    let(:tested_method) { ArchivedConvictsDestroy.perform_later }

    it 'queues the job' do
      tested_method
      expect(ArchivedConvictsDestroy).to have_been_enqueued.once
    end
  end

  describe '#perform' do
    let(:convict1) { create :convict }
    let(:convict2) { create :convict }
    let(:convict3) { create :convict }

    before do
      allow(Time).to receive(:now).and_return Time.zone.parse('2021-02-02')
      convict3
      convict1.discard
      allow(Time).to receive(:now).and_return Time.zone.parse('2021-04-04')
      convict2.discard
      allow(Time).to receive(:now).and_return Time.zone.parse('2021-09-09')
      ArchivedConvictsDestroy.new.perform
    end

    it 'delete fully convict deleted 7 months ago' do
      expect(Convict.exists?(id: convict1.id)).to be false
    end
    it 'does not delete fully convict deleted 5 months ago' do
      expect(Convict.exists?(id: convict2.id)).to be true
    end
    it 'does not delete fully convict not deleted' do
      expect(Convict.exists?(id: convict3.id)).to be true
    end
  end
end
