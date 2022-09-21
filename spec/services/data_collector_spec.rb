require 'rails_helper'

RSpec.describe DataCollector do
  describe 'User' do
    describe 'perform' do
      it 'collects data' do
        convict1 = create :convict, phone: '0606060606'
        convict2 = create :convict, phone: nil, refused_phone: true

        3.times { create :user }

        slot1 = create :slot, date: Date.civil(2025, 4, 14)
        slot2 = create :slot, date: Date.civil(2022, 4, 11)

        apt1 = create :appointment, state: 'booked', convict: convict1, slot: slot1
        create :appointment, :skip_validate, state: 'booked', convict: convict1, slot: slot2

        create :appointment, :skip_validate, state: 'fulfiled', convict: convict1, slot: slot2
        create :appointment, :skip_validate, state: 'fulfiled', convict: convict2, slot: slot2
        create :appointment, :skip_validate, state: 'no_show', convict: convict1, slot: slot2
        create :appointment, :skip_validate, state: 'excused', convict: convict1, slot: slot2
        create :appointment, :skip_validate, state: 'canceled', convict: convict1, slot: slot2

        create :notification, appointment: apt1, state: 'sent'

        expected = {
          convicts: 2,
          convicts_with_phone: 1,
          users: 3,
          notifications: 1,
          recorded: 7,
          future_booked: 1,
          passed_uninformed: 1,
          passed_uninformed_percentage: 25,
          passed_informed: 3,
          passed_no_canceled_with_phone: 4,
          fulfiled: 1,
          fulfiled_percentage: 33,
          no_show: 1,
          no_show_percentage: 33,
          excused: 1,
          excused_percentage: 33
        }

        result = DataCollector::User.new.perform

        expect(result).to eq(expected)
      end

      it 'can be scoped by organization' do
        orga = create :organization

        create :user, organization: orga
        create :user

        result = DataCollector::User.new(organization_id: orga.id).perform

        expect(result[:users]).to eq(1)
      end
    end
  end

  describe 'Sda' do
    describe 'perform' do
      it 'collects data' do
        convict = create :convict, phone: '0606060606'
        apt_type1 = create :appointment_type, name: "Sortie d'audience SPIP"
        slot1 = create :slot, :skip_validate, appointment_type: apt_type1, date: Date.civil(2022, 4, 11), capacity: 20

        create :appointment, :skip_validate, slot: slot1, convict: convict,
                                             state: 'booked', created_at: Date.civil(2022, 3, 11)
        create :appointment, :skip_validate, slot: slot1, convict: convict,
                                             state: 'fulfiled', created_at: Date.civil(2022, 3, 11)
        create :appointment, :skip_validate, slot: slot1, convict: convict,
                                             state: 'fulfiled', created_at: Date.civil(2022, 3, 11)
        create :appointment, :skip_validate, slot: slot1, convict: convict,
                                             state: 'no_show', created_at: Date.civil(2022, 3, 11)
        create :appointment, :skip_validate, slot: slot1, convict: convict,
                                             state: 'excused', created_at: Date.civil(2022, 3, 11)
        create :appointment, :skip_validate, slot: slot1, convict: convict,
                                             state: 'canceled', created_at: Date.civil(2022, 3, 11)

        apt_type2 = create :appointment_type, name: "Sortie d'audience SAP"
        slot2 = create :slot, :skip_validate, appointment_type: apt_type2, date: Date.civil(2022, 4, 11), capacity: 20

        create :appointment, :skip_validate, slot: slot2, convict: convict,
                                             state: 'booked', created_at: Date.civil(2022, 3, 11)
        create :appointment, :skip_validate, slot: slot2, convict: convict,
                                             state: 'fulfiled', created_at: Date.civil(2022, 3, 11)
        create :appointment, :skip_validate, slot: slot2, convict: convict,
                                             state: 'fulfiled', created_at: Date.civil(2022, 3, 11)
        create :appointment, :skip_validate, slot: slot2, convict: convict,
                                             state: 'no_show', created_at: Date.civil(2022, 3, 11)
        create :appointment, :skip_validate, slot: slot2, convict: convict,
                                             state: 'excused', created_at: Date.civil(2022, 3, 11)
        create :appointment, :skip_validate, slot: slot2, convict: convict,
                                             state: 'canceled', created_at: Date.civil(2022, 3, 11)

        expected = {
          sortie_audience_spip: {
            average_delay: 31.0,
            convicts: 1,
            recorded: 6,
            future_booked: 0,
            passed_no_canceled_with_phone: 5,
            passed_uninformed: 1,
            passed_uninformed_percentage: 20,
            passed_informed: 4,
            fulfiled: 2,
            fulfiled_percentage: 50,
            no_show: 1,
            no_show_percentage: 25,
            excused: 1,
            excused_percentage: 25
          },
          sortie_audience_sap: {
            average_delay: 31.0,
            convicts: 1,
            recorded: 6,
            future_booked: 0,
            passed_no_canceled_with_phone: 5,
            passed_uninformed: 1,
            passed_uninformed_percentage: 20,
            passed_informed: 4,
            fulfiled: 2,
            fulfiled_percentage: 50,
            no_show: 1,
            no_show_percentage: 25,
            excused: 1,
            excused_percentage: 25
          }
        }

        result = DataCollector::Sda.new.perform

        expect(result).to eq(expected)
      end
    end
  end
end
