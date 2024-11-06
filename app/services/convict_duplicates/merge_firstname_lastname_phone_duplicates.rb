module ConvictDuplicates
  # This class is responsible for merging duplicates convicts
  # based on the first_name, last_name and date_of_birth attributes.
  class MergeFirstnameLastnamePhoneDuplicates
    attr_reader :duplicates

    def initialize
      @duplicates = Convict
                    .where.not(phone: [nil, ''])
                    .where.not(first_name: [nil, ''])
                    .where.not(last_name: [nil, ''])
                    .select(
                      'LOWER(TRIM(first_name)) as cleaned_fn, ' \
                      'LOWER(TRIM(last_name)) as cleaned_ln, ' \
                      'phone, COUNT(*) as duplicates_count'
                    )
                    .group('cleaned_fn', 'cleaned_ln', :phone)
                    .having('COUNT(*) > 1')
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/PerceivedComplexity
    # rubocop:disable Metrics/MethodLength
    def perform
      @duplicates.each do |dup|
        group = Convict
                .where('LOWER(TRIM(first_name)) = ?', dup.cleaned_fn)
                .where('LOWER(TRIM(last_name)) = ?', dup.cleaned_ln)
                .where('phone = ?', dup.phone)
        group_with_appointments = group.select do |convict|
          convict.appointments.any?
        end

        most_active = group_with_appointments.max_by do |convict|
          convict.appointments.joins(:slot).order('slots.date DESC').first&.slot&.date
        end || group.first

        mergeable = (group - [most_active]).reject do |convict|
          convict.appointments.any? &&
            (convict.appointments.joins(:slot).order('slots.date DESC').first&.slot&.date&.> 12.months.ago) && # rubocop:disable Style/SafeNavigationChainLength
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
