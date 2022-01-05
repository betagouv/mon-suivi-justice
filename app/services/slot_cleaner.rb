module SlotCleaner
  class << self
    def perform(agenda_id:, data:)
      data.each do |day|
        Slot.where(
          agenda_id: agenda_id,
          date: day[:date],
          starting_time: day[:starting_times]
        ).delete_all
      end
    end
  end
end
