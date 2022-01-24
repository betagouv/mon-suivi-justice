# == Schema Information
#
# Table name: agendas
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  place_id   :bigint
#
# Indexes
#
#  index_agendas_on_place_id  (place_id)
#
# Foreign Keys
#
#  fk_rails_...  (place_id => places.id)
#
FactoryBot.define do
  factory :agenda do
    name { 'agenda Test' }
    place
  end
end
