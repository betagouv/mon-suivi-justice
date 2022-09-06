#
# Load supported french jurisdictions defined in db/jurisdictions.json
#
FRENCH_JURISDICTIONS = Proc.new do
  JSON.parse(File.read('./db/jurisdictions.json'))
rescue StandardError
  []
end.call
