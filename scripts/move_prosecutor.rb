# rails r scripts/move_prosecutor.rb

require 'ruby-progressbar'

progress = ProgressBar.create(total: Convict.count)

Convict.find_each do |convict|
  number = convict.prosecutor_number
  convict.appointments.each do |appointment|
    appointment.prosecutor_number = number
    appointment.save!
  end
  progress.increment
end

p "Data moved"
