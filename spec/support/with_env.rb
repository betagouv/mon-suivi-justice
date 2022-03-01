module WithEnv
  def with_env(key, value)
    around do |example|
      old_value = ENV[key]
      ENV[key] = value
      example.run
    ensure
      ENV.delete(key)
      ENV[key] = old_value if old_value
    end
  end
end

RSpec.configure do |config|
  config.extend WithEnv
end
