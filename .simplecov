SimpleCov.start "rails" do
  coverage_dir "public/coverage"

  add_filter "/bin/"
  add_filter "/db/"
  add_filter "/test/"
  add_filter "/config/"
  add_filter "/vendor/"

  # Enable JSON formatter for Codecov
  if ENV["CI"]
    require "simplecov-json"
    SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new([
      SimpleCov::Formatter::HTMLFormatter,
      SimpleCov::Formatter::JSONFormatter
    ])
  end

  minimum_coverage 100 if ENV["ENFORCE_COVERAGE"]
end
