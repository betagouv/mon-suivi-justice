desc 'invite convicts to their interface when first appointment is passed'
task invite_convicts_to_interface: :environment do
  unless ENV['APP'] == 'mon-suivi-justice-prod'
    Convict.never_invited.with_phone.with_past_appointments.each do |convict|
      InviteConvictJob.perform_later(convict.id)
    end
  end
end
