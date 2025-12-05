SimpleCov.start "rails" do
  coverage_dir "public/coverage"

  add_filter "/bin/"
  add_filter "/db/"
  add_filter "/test/"
  add_filter "/config/"
  add_filter "/vendor/"
end
