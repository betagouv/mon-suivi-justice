#
# Load supported french departments defined in db/department.json
#
FRENCH_DEPARTMENTS = Proc.new do
  JSON.parse(File.read('./db/department.json')).map { |dpt| OpenStruct.new(name: dpt['name'], number: dpt['number'])}
rescue StandardError
  []
end.call
