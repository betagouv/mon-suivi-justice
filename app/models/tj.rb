class Tj < ApplicationRecord
  belongs_to :organization, optional: true
  belongs_to :city
end
