module Cleanup
  class DeleteUnactiveConvicts
    attr_reader :convicts

    def initialize
      delay = Convict.delete_delay
      @convicts = Convict
                  .where('NOT EXISTS (
        SELECT 1 FROM appointments
        INNER JOIN slots ON slots.id = appointments.slot_id
        WHERE appointments.convict_id = convicts.id
        AND slots.date > ?
        )', delay)
                  .where('created_at < ?', delay)
    end

    def call
      Convict.transaction do
        @convicts.destroy_all
      end
    end
  end
end
