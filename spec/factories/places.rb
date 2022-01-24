# == Schema Information
#
# Table name: places
#
#  id              :bigint           not null, primary key
#  adress          :string
#  name            :string
#  phone           :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :bigint
#
# Indexes
#
#  index_places_on_organization_id  (organization_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations.id)
#
FactoryBot.define do
  factory :place do
    name { 'Spip du 92' }
    adress { 'fake adress' }
    phone { '0606060606' }
    organization
  end
end
