module TransfertValidator
  extend ActiveSupport::Concern

  # The code inside the included block is evaluated
  # in the context of the class that includes the Visible concern.
  # You can write class macros here, and
  # any methods become instance methods of the including class.
  included do
    validate :handle_transfert, on: %i[create update]

    def should_add_transfert_in_error?
      place.transfert_in && date < place.transfert_in.date
    end

    def should_add_transfert_out_error?
      place.transfert_out && date >= place.transfert_out.date
    end

    def handle_transfert
      add_transfert_error(place.transfert_in, :transfert_in) if should_add_transfert_in_error?
      add_transfert_error(place.transfert_out, :transfert_out) if should_add_transfert_out_error?
    end
  end
end
