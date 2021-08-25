module Phone
  def self.display(num_as_string)
    num_as_string.phony_formatted(normalize: 'FR', format: :national, spaces: ' ')
  end
end
