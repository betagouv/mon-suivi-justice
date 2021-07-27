module Phone
  REGEX = /(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})/

  def self.display(num_as_string)
    num_as_string.gsub(REGEX, '\1 \2 \3 \4 \5')
  end

  def self.format(num_as_string)
    return unless num_as_string.start_with?('0')

    num_as_string.slice!(0)
    num_as_string.prepend('+33')
  end
end
