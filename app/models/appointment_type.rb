class AppointmentType < ApplicationRecord
  has_many :notifications

  validates :name, presence: true

  def form_label
    name
  end
end
