module Cleanup
  class DeleteUnactiveConvicts
    attr_reader :convicts

    @delay = 18.months.ago
    def initialize
      @convicts = Convict
                  .where('NOT EXISTS (
                    SELECT 1 FROM appointments
                    INNER JOIN slots ON slots.id = appointments.slot_id
                    WHERE appointments.convict_id = convicts.id
                    AND slots.date > ?
                  )', @delay)
                  .where('convicts.created_at < ?', @delay)
    end

    def call
      @convicts.delete_all
    end
  end
end
