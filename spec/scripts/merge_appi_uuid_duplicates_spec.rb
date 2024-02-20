require 'rails_helper'

RSpec.describe MergeAppiUuidDuplicates, type: :service do
  describe '#perform' do
    let(:duplicate_appi_uuid) { "2024#{Faker::Number.unique.number(digits: 8)}" }
    let!(:convict1) { create(:convict, no_phone: true) }
    let!(:convict2) { create(:convict, appi_uuid: " #{duplicate_appi_uuid} ") }
    let!(:convict3) do
      slot = build(:slot, date: 2.month.ago)
      apt = build(:appointment, slot:)
      apt.save(validate: false)
      conv = build(:convict, appi_uuid: "#{duplicate_appi_uuid} ",
                             appointments: [apt])
      conv.save(validate: false)
      conv
    end
    let!(:convict4) do
      slot = build(:slot, date: 1.year.ago)
      apt = build(:appointment, slot:)
      apt.save(validate: false)
      conv = build(:convict, appi_uuid: "#{duplicate_appi_uuid} ",
                             appointments: [apt])
      conv.save(validate: false)
      conv
    end
    let!(:unique_convict) do
      create(:convict, appi_uuid: "2024#{Faker::Number.unique.number(digits: 8)}", no_phone: true)
    end

    before do
      MergeAppiUuidDuplicates.new.perform
    end

    it 'merges duplicates based on appi_uuid, ignoring whitespaces' do
      expect(Convict.where('TRIM(appi_uuid) = ?', duplicate_appi_uuid).count).to eq(1)
    end

    it 'keeps the most active convict based on appointments' do
      expect(Convict.exists?(id: convict3.id)).to be true
      expect(Appointment.where(convict_id: convict3.id).count).to eq(2)
    end

    it 'deletes the less active duplicates' do
      expect(Convict.exists?(id: convict2.id)).to be false
    end

    it 'does not affect convicts with unique appi_uuid' do
      expect(Convict.exists?(id: unique_convict.id)).to be true
    end

    it 'does not affect convicts without appi_uuid' do
      expect(Convict.exists?(id: convict1.id)).to be true
    end
  end
end
