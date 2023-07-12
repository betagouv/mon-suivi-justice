# rails appointment_types:rename
namespace :appointment_types do
  desc 'Rename appointment_types'
  task rename: :environment do
    new_names = {
      '1er RDV SPIP' => '1ère convocation de suivi SPIP',
      'RDV de suivi SPIP' => 'Convocation de suivi SPIP',
      'RDV DDSE' => 'Convocation DDSE',
      'RDV téléphonique' => 'RDV téléphonique',
      'RDV de suivi JAP' => 'Convocation de suivi JAP',
      'RDV JAPAT' => 'Convocation JAPAT'
    }

    new_names.each do |old_name, new_name|
      appointment_type = AppointmentType.find_by(name: old_name)
      if appointment_type
        appointment_type.update(name: new_name)
        puts "Renamed #{old_name} to #{new_name}"
      else
        puts "Appointment type '#{old_name}' not found"
      end
    end
  end
end
