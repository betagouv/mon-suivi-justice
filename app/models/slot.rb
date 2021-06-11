class Slot < ApplicationRecord
  belongs_to :place

  validates :date, :starting_time, presence: true

  scope :for_place, ->(place) { where(place_id: place.id) }

  def form_label
    date.to_s(:base_date_format) + ' - ' + starting_time.to_s(:time)
  end
end
