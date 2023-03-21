class SrjTj < ApplicationRecord
  belongs_to :organization, optional: true
  has_one :city

  def short_name
    name.gsub(%r{Tribunal judiciaire / Tribunal de Grande Instance}, 'TJ')
  end
end
