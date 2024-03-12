require 'rails_helper'

RSpec.describe ConvictDuplicates, type: :service do
  describe 'MergeAppiUuidDuplicates' do
    describe 'perform' do
      let(:duplicate_appi_uuid) { "2024#{Faker::Number.unique.number(digits: 8)}" }
      let!(:convict1) { create(:convict, no_phone: true) }
      let!(:convict2) { create(:convict, appi_uuid: " #{duplicate_appi_uuid} ") }
      let!(:convict3) do
        conv = build(:convict, appi_uuid: "#{duplicate_appi_uuid} ")
        conv.save(validate: false)
        slot = build(:slot, date: 2.month.ago)
        apt = build(:appointment, slot:, convict: conv)
        apt.save(validate: false)
        conv
      end
      let!(:convict4) do
        conv = build(:convict, appi_uuid: "#{duplicate_appi_uuid} ")
        conv.save(validate: false)
        slot = build(:slot, date: 1.year.ago)
        apt = build(:appointment, slot:, convict: conv)
        apt.save(validate: false)
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
        conv = build(:convict, first_name: duplicate_first_name, last_name: duplicate_last_name,
                               phone: duplicate_phone_number)
        conv.save(validate: false)
        slot = build(:slot, date: 2.month.ago)
        apt = build(:appointment, slot:, convict: conv)
        apt.save(validate: false)
        conv
      end
      let!(:convict4) do
        conv = build(:convict, first_name: "#{duplicate_first_name} ", last_name: duplicate_last_name,
                               phone: duplicate_phone_number)
        conv.save(validate: false)
        slot = build(:slot, date: 1.year.ago)
        apt = build(:appointment, slot:, convict: conv)
        apt.save(validate: false)
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
  describe 'MergeFirstnameLastnameDobDuplicates' do
    describe 'perform' do
      let(:duplicate_dob) { Faker::Date.unique.birthday(min_age: 18, max_age: 65) }
      let(:duplicate_first_name) { Faker::Name.unique.first_name }
      let(:duplicate_last_name) { Faker::Name.unique.last_name }
      let!(:convict1) do
        convict_without_dob = build(:convict, no_phone: true, date_of_birth: nil,
                                              first_name: duplicate_first_name, last_name: duplicate_last_name)
        convict_without_dob.save(validate: false)
        convict_without_dob
      end
      let!(:convict2) do
        create(:convict, first_name: duplicate_first_name, last_name: duplicate_last_name,
                         date_of_birth: duplicate_dob)
      end
      let!(:convict3) do
        conv = build(:convict, first_name: duplicate_first_name, last_name: duplicate_last_name,
                               date_of_birth: duplicate_dob)
        slot = build(:slot, date: 2.month.ago)
        apt = build(:appointment, slot:, convict: conv)
        apt.save(validate: false)
        conv.save(validate: false)
        conv
      end
      let!(:convict4) do
        conv = build(:convict, first_name: "#{duplicate_first_name} ", last_name: duplicate_last_name,
                               date_of_birth: duplicate_dob)
        slot = build(:slot, date: 1.year.ago)
        apt = build(:appointment, slot:, convict: conv)
        apt.save(validate: false)
        conv.save(validate: false)
        conv
      end
      let!(:unique_convict) do
        create(:convict, first_name: Faker::Name.unique.first_name, last_name: Faker::Name.unique.last_name,
                         date_of_birth: Faker::Date.unique.birthday(min_age: 18, max_age: 65))
      end

      before do
        @service = ConvictDuplicates::MergeFirstnameLastnameDobDuplicates.new
        @service.perform
      end

      it 'keeps the most active convict based on appointments' do
        key = @service.key_from_duplicate(@service.duplicates.first)
        expect(@service.dup_data[key][:most_active].id).to eq(convict3.id)
      end

      it 'deletes the less actives duplicates' do
        key = @service.key_from_duplicate(@service.duplicates.first)
        expect(@service.dup_data[key][:mergeable]).to match_array([convict4, convict2])
      end

      it 'does not affect convicts with unique dob' do
        key = @service.key_from_duplicate(@service.duplicates.first)
        expect(@service.dup_data[key][:mergeable]).not_to include(unique_convict)
      end

      it 'does not affect convicts without dob' do
        key = @service.key_from_duplicate(@service.duplicates.first)
        expect(@service.dup_data[key][:mergeable]).not_to include(convict1)
      end
    end
  end
end
