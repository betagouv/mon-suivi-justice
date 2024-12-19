module Convicts
  class MergeService
    def self.call(kept_id:, duplicated_id:)
      kept_convict = Convict.find(kept_id)
      duplicated_convict = Convict.find(duplicated_id)
      ActiveRecord::Base.transaction do
        duplicated_convict.appointments.update_all(convict_id: kept_convict.id)
        duplicated_convict.history_items.update_all(convict_id: kept_convict.id)

        kept_convict.save!(validate: false)

        duplicated_convict.destroy!
      end

      kept_convict
    end
  end
end
