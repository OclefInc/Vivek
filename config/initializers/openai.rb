OpenAI.configure do |config|
  config.access_token = ENV.fetch("OPENAI_ACCESS_TOKEN", "dummy_key_for_now")
  config.log_errors = true # Highly recommended in development, so you can see what errors OpenAI is returning. Not recommended in production.
end
