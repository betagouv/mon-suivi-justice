#
# Load supported french departments defined in db/department.json
#
FRENCH_JURISDICTIONS = Proc.new do
  JSON.parse(File.read('./db/jurisdictions.json'))
rescue StandardError
  []
end.call
