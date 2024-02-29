module ConvictDuplicates
  class MergeFirstnameLastnameDobDuplicates
    def initialize
      @duplicates = Convict
                    .where.not(date_of_birth: nil)
                    .where.not(first_name: nil)
                    .where.not(last_name: nil)
                    .select(
                      'LOWER(TRIM(first_name)) as cleaned_fn, ' \
                      'LOWER(TRIM(last_name)) as cleaned_ln, ' \
                      'date_of_birth, COUNT(*) as duplicates_count'
                    )
                    .group('cleaned_fn', 'cleaned_ln', :date_of_birth)
                    .having('COUNT(*) > 1')

      p @duplicates
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
            (convict.appointments.joins(:slot).order('slots.date DESC').first&.slot&.date&.> 12.months.ago) &&
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
