require 'rails_helper'

RSpec.describe HistoryItemFactory do
  describe 'perform' do
    it 'creates HistoryItem for an event' do
      appointment = create :appointment
      event = :book_appointment
      category = 'appointment'

      expect do
        HistoryItemFactory.perform(appointment:, event:, category:)
      end.to change { HistoryItem.count }.by(1)

      expected_content = "#{appointment.convict.name} a été convoqué " \
                         "le #{appointment.slot.date.to_fs} " \
                         "à #{appointment.localized_time.to_fs(:time)} " \
                         "au lieu suivant : #{appointment.slot.agenda.place.name}."

      last = HistoryItem.last

      expect(last.content).to eq(expected_content)
    end
  end
end
