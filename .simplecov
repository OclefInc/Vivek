require "simplecov-lcov"

SimpleCov::Formatter::LcovFormatter.config.report_with_single_file = true
SimpleCov::Formatter::LcovFormatter.config.single_report_path = "public/coverage/lcov.info"

SimpleCov.start "rails" do
  coverage_dir "public/coverage"

  if ENV["CI"]
    formatter SimpleCov::Formatter::LcovFormatter
  end

  add_filter "/bin/"
  add_filter "/db/"
  add_filter "/test/"
  add_filter "/config/"
  add_filter "/vendor/"

  minimum_coverage 100 if ENV["ENFORCE_COVERAGE"]
end
