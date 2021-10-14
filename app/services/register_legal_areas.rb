class RegisterLegalAreas
  #
  # Attach a convict to all juridiction/department of some Organizations
  # <from> argument can be a single organization or a collection of
  # Example
  # RegisterLegalAreas.for_convict @convict, from: Organization.where(name: ['Spip92', 'Tribunal de nanterre'])
  # RegisterLegalAreas.for_convict @convict, from: Organization.take
  #
  def self.for_convict(convict, from:)
    return unless Convict.exists? id: convict&.id

    AreasOrganizationsMapping.where(organization: from).find_each do |mapping|
      AreasConvictsMapping.create convict: convict, area: mapping.area
    end
  end
end
