module Cleanup
  class ArchiveUnactiveConvicts
    attr_reader :convicts

    def initialize
      delay = Convict.archive_delay
      @convicts = Convict.where('NOT EXISTS (
                    SELECT 1 FROM appointments
                    INNER JOIN slots ON slots.id = appointments.slot_id
                    WHERE appointments.convict_id = convicts.id
                    AND slots.date > ?
                  )', delay)
                         .where(created_at: ..delay)
                         .where(discarded_at: nil)
                         .where.not(id: Divestment.where(state: :pending).select(:convict_id))
                         .joins(:convicts_organizations_mappings)
                         .where.not(convicts_organizations_mappings: { created_at: delay.. }).distinct
      # Pas de divestment en cours ni de changement de service dans le delay
    end

    def call
      @convicts.each do |convict|
        convict.discard
        HistoryItemFactory.perform(convict:, event: 'archive_convict', category: 'convict')
      end
    end
  end
end
