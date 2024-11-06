module ConvictDuplicates
  class MergeFirstnameLastnameDobDuplicates
    attr_reader :duplicates, :dup_data

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
      @dup_data = {}
    end

    def key_from_duplicate(dup)
      "#{dup.date_of_birth&.to_fs}_#{dup.cleaned_fn}_#{dup.cleaned_ln}"
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/PerceivedComplexity
    # rubocop:disable Metrics/MethodLength
    def perform
      @duplicates.each do |dup|
        group = Convict.where('LOWER(TRIM(first_name)) = ?', dup.cleaned_fn)
                       .where('LOWER(TRIM(last_name)) = ?', dup.cleaned_ln)
                       .where('date_of_birth = ?', dup.date_of_birth)
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

        dup_key = key_from_duplicate(dup)
        @dup_data[dup_key] ||= {}
        @dup_data[dup_key][:most_active] = most_active
        @dup_data[dup_key][:mergeable] = mergeable
        @dup_data[dup_key][:group] = group
        @dup_data[dup_key][:group_with_appointments] = group_with_appointments
      end
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/PerceivedComplexity
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/AbcSize
  end
end
