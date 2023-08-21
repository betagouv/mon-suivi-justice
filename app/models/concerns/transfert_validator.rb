module TransfertValidator
  extend ActiveSupport::Concern

  # The code inside the included block is evaluated
  # in the context of the class that includes the Visible concern.
  # You can write class macros here, and
  # any methods become instance methods of the including class.
  included do
    validate :handle_transfert, on: %i[create update]

    def should_add_transfert_in_error?
      return false unless place.transfert_in&.present?

      date < place.transfert_in.date
    end

    def should_add_transfert_out_error?
      return false unless place.transfert_out&.present?

      date >= place.transfert_out.date
    end

    # rubocop:disable Metrics/AbcSize
    def handle_transfert
      return unless agenda.present? && date.present?

      if should_add_transfert_in_error?
        add_transfert_error(place.transfert_in, :transfert_in,
                            place.transfert_in.old_place.name)
      end
      return unless should_add_transfert_out_error?

      add_transfert_error(place.transfert_out, :transfert_out,
                          place.transfert_out.new_place.name)
    end
    # rubocop:enable Metrics/AbcSize
  end
end
