class NormalizePhone < ActiveRecord::Migration[6.1]
  #
  # One shot migration to apply Phony gem normalization on all Convict & Place phone number
  #
  def up
    Place.where.not(phone: nil).find_each(&:save) if defined? Place
    Convict.where.not(phone: nil).find_each(&:save) if defined? Convict
  end

  def down
  end
end
