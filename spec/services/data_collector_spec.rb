require 'rails_helper'

RSpec.describe DataCollector do
  describe 'perform' do
    it 'collects data' do
      convict1 = create :convict, phone: '0606060606'
      convict2 = create :convict, phone: nil, refused_phone: true

      3.times { create :user }

      slot1 = create :slot, date: Date.current.tomorrow
      slot2 = create :slot, date: Date.current.yesterday

      apt1 = create :appointment, state: 'booked', convict: convict1, slot: slot1
      create :appointment, state: 'booked', convict: convict1, slot: slot2

      create :appointment, state: 'fulfiled', convict: convict1, slot: slot2
      create :appointment, state: 'fulfiled', convict: convict2, slot: slot2
      create :appointment, state: 'no_show', convict: convict1, slot: slot2
      create :appointment, state: 'excused', convict: convict1, slot: slot2
      create :appointment, state: 'canceled', convict: convict1, slot: slot2

      create :notification, appointment: apt1, state: 'sent'

      expected = {
        convicts: 2,
        convicts_with_phone: 1,
        users: 3,
        notifications: 1,
        recorded: 7,
        future_booked: 1,
        passed_booked: 1,
        passed_booked_percentage: 20,
        passed_no_canceled: 5,
        passed_no_canceled_with_phone: 4,
        fulfiled: 1,
        fulfiled_percentage: 25,
        no_show: 1,
        no_show_percentage: 25,
        excused: 1
      }

      result = DataCollector.new.perform

      expect(result).to eq(expected)
    end

    it 'can be scoped by organization' do
      orga = create :organization

      create :user, organization: orga
      create :user

      result = DataCollector.new(organization_id: orga.id).perform

      expect(result[:users]).to eq(1)
    end
  end
end
