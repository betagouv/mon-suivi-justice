module ConvictDuplicates
  # This class is responsible for merging duplicates convicts
  # based on the appi_uuid attribute.
  class MergeAppiUuidDuplicates
    def initialize
      @duplicates = Convict
                    .select('TRIM(appi_uuid) as trimmed_appi_uuid, COUNT(*)')
                    .where.not(appi_uuid: [nil, ''])
                    .group('trimmed_appi_uuid')
                    .having('COUNT(*) > 1')
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/PerceivedComplexity
    # rubocop:disable Metrics/MethodLength
    def perform
      @duplicates.each do |dup|
        group = Convict.where('TRIM(appi_uuid) = ?', dup.trimmed_appi_uuid)
        group_with_appointments = group.select do |convict|
          convict.appointments.any?
        end

        most_active = group_with_appointments.max_by do |convict|
          convict.appointments.joins(:slot).order('slots.date DESC').first&.slot&.date
        end || group.first

        mergeable = (group - [most_active]).reject do |convict|
          convict.appointments.any? &&
            (convict.appointments.joins(:slot).order('slots.date DESC').first&.slot&.date&.> 6.months.ago) && # rubocop:disable Style/SafeNavigationChainLength
            convict.undiscarded?
        end

        ActiveRecord::Base.transaction do
          mergeable.each do |duplicated_convict|
            duplicated_convict.appointments.update_all(convict_id: most_active.id)
            duplicated_convict.history_items.update_all(convict_id: most_active.id)

            most_active.save
            duplicated_convict.destroy!
          end
        end
      end
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/PerceivedComplexity
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/AbcSize
  end
end
