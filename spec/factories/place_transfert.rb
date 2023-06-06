FactoryBot.define do
  factory :place_transfert do
    date { Date.today }
    new_place { build(:place) }
    old_place { build(:place) }
    status { :transfert_pending }
  end
end
