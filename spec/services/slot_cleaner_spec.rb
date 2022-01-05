require 'rails_helper'

RSpec.describe SlotCleaner, :focus do
  it 'deletes batch of slots' do
    agenda = create(:agenda)

    create(:slot, agenda: agenda, date: '06/06/2021', starting_time: new_time_for(13, 0))
    create(:slot, agenda: agenda, date: '06/06/2021', starting_time: new_time_for(14, 0))
    create(:slot, agenda: agenda, date: '06/06/2021', starting_time: new_time_for(15, 0))
    create(:slot, agenda: agenda, date: '06/06/2021', starting_time: new_time_for(16, 0))

    create(:slot, agenda: agenda, date: '08/06/2021', starting_time: new_time_for(13, 0))
    create(:slot, agenda: agenda, date: '08/06/2021', starting_time: new_time_for(14, 0))
    create(:slot, agenda: agenda, date: '08/06/2021', starting_time: new_time_for(15, 0))

    input = [{ date: '06/06/2021', starting_times: ['13:00'] }]

    expect do
      SlotCleaner.perform(agenda_id: agenda.id, data: input)
    end.to change { Slot.count }.by(-1)

    input2 = [{ date: '06/06/2021', starting_times: ['14:00', '15:00'] }]

    expect do
      SlotCleaner.perform(agenda_id: agenda.id, data: input2)
    end.to change { Slot.count }.by(-2)

    input3 = [
      { date: '06/06/2021', starting_times: ['16:00'] },
      { date: '08/06/2021', starting_times: ['14:00', '15:00'] }
    ]

    expect do
      SlotCleaner.perform(agenda_id: agenda.id, data: input3)
    end.to change { Slot.count }.by(-3)
  end
end
