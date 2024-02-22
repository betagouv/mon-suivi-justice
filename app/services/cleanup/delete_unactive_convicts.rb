module Cleanup
  class DeleteUnactiveConvicts
    attr_reader :convicts

    def initialize
      @delay = 18.months.ago
      @convicts = Convict
                  .where('NOT EXISTS (
        SELECT 1 FROM appointments
        INNER JOIN slots ON slots.id = appointments.slot_id
        WHERE appointments.convict_id = convicts.id
        AND slots.date > ?
        )', @delay)
                  .where('created_at < ?', @delay)
    end

    def call
      Convict.transaction do
        @convicts.find_each do |convict|
          # Delete or handle appointments before deleting the convict
          convict.appointments.delete_all
          convict.delete
        end
      end
    end
  end
end
