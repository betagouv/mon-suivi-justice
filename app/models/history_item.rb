class HistoryItem < ApplicationRecord
  belongs_to :convict
  belongs_to :appointment

  enum event: %i[
    book_appointment
    cancel_appointment
    fulfil_appointment
    miss_appointment
  ]
end
