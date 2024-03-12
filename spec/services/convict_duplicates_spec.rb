require 'rails_helper'

RSpec.describe ConvictDuplicates, type: :service do
  describe 'MergeAppiUuidDuplicates' do
    describe 'perform' do
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
        ConvictDuplicates::MergeAppiUuidDuplicates.new.perform
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
  describe 'MergeFirstnameLastnamePhoneDuplicates' do
    describe 'perform' do
      let(:duplicate_phone_number) { '+33666238641' }
      let(:duplicate_first_name) { Faker::Name.unique.first_name }
      let(:duplicate_last_name) { Faker::Name.unique.last_name }
      let!(:convict1) { create(:convict, no_phone: true) }
      let!(:convict2) do
        create(:convict, first_name: duplicate_first_name, last_name: duplicate_last_name,
                         phone: duplicate_phone_number)
      end
      let!(:convict3) do
        slot = build(:slot, date: 2.month.ago)
        apt = build(:appointment, slot:)
        apt.save(validate: false)
        conv = build(:convict, first_name: duplicate_first_name, last_name: duplicate_last_name,
                               appointments: [apt], phone: duplicate_phone_number)
        conv.save(validate: false)
        conv
      end
      let!(:convict4) do
        slot = build(:slot, date: 1.year.ago)
        apt = build(:appointment, slot:)
        apt.save(validate: false)
        conv = build(:convict, first_name: "#{duplicate_first_name} ", last_name: duplicate_last_name,
                               appointments: [apt], phone: duplicate_phone_number)
        conv.save(validate: false)
        conv
      end
      let!(:unique_convict) do
        create(:convict, first_name: Faker::Name.unique.first_name, last_name: Faker::Name.unique.last_name,
                         phone: '0677238642')
      end

      before do
        ConvictDuplicates::MergeFirstnameLastnamePhoneDuplicates.new.perform
      end

      it 'keeps the most active convict based on appointments' do
        expect(Convict.exists?(id: convict3.id)).to be true
        expect(Appointment.where(convict_id: convict3.id).count).to eq(2)
      end

      it 'deletes the less actives duplicates' do
        expect(Convict.exists?(id: convict2.id)).to be false
        expect(Convict.exists?(id: convict4.id)).to be false
      end

      it 'does not affect convicts with unique phone' do
        expect(Convict.exists?(id: unique_convict.id)).to be true
      end

      it 'does not affect convicts without phone' do
        expect(Convict.exists?(id: convict1.id)).to be true
      end
    end
  end
end
