module Cleanup
  class ArchiveUnactiveConvicts
    attr_reader :convicts

    def initialize
      delay = Convict.archive_delay
      @convicts = Convict
                  .where('NOT EXISTS (
                    SELECT 1 FROM appointments
                    INNER JOIN slots ON slots.id = appointments.slot_id
                    WHERE appointments.convict_id = convicts.id
                    AND slots.date > ?
                  )', delay)
                  .where('convicts.created_at < ?', delay)
                  .where(discarded_at: nil)
    end

    def call
      @convicts.each do |convict|
        convict.discard
        HistoryItemFactory.perform(convict:, event: 'archive_convict', category: 'convict')
      end
    end
  end
end
