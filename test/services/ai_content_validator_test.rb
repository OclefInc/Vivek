require "test_helper"

class AiContentValidatorTest < ActiveSupport::TestCase
  test "initializes client" do
    AiContentValidator.instance_variable_set(:@client, nil)
    assert_instance_of OpenAI::Client, AiContentValidator.client
  end

  test "returns true if text is blank" do
    valid, reason = AiContentValidator.validate("")
    assert valid
    assert_nil reason

    valid, reason = AiContentValidator.validate(nil)
    assert valid
    assert_nil reason
  end

  test "returns true if API key is missing" do
    with_env("OPENAI_ACCESS_TOKEN" => nil) do
      # Should not call client
      AiContentValidator.expects(:client).never

      valid, reason = AiContentValidator.validate("some text")
      assert valid
      assert_nil reason
    end
  end

  test "returns true if content is safe" do
    with_env("OPENAI_ACCESS_TOKEN" => "test_key") do
      mock_response = {
        "choices" => [
          { "message" => { "content" => "SAFE" } }
        ]
      }

      client_mock = mock
      client_mock.expects(:chat).with(has_key(:parameters)).returns(mock_response)
      AiContentValidator.stubs(:client).returns(client_mock)

      valid, reason = AiContentValidator.validate("Hello world")
      assert valid
      assert_nil reason
    end
  end

  test "returns false and reason if content is unsafe" do
    with_env("OPENAI_ACCESS_TOKEN" => "test_key") do
      mock_response = {
        "choices" => [
          { "message" => { "content" => "UNSAFE: This is spam" } }
        ]
      }

      client_mock = mock
      client_mock.expects(:chat).returns(mock_response)
      AiContentValidator.stubs(:client).returns(client_mock)

      valid, reason = AiContentValidator.validate("Spam content")
      assert_not valid
      assert_equal "This is spam", reason
    end
  end

  test "returns true if API raises error" do
    with_env("OPENAI_ACCESS_TOKEN" => "test_key") do
      client_mock = mock
      client_mock.expects(:chat).raises(StandardError.new("API Error"))
      AiContentValidator.stubs(:client).returns(client_mock)

      # Should log error but return true (fail open)
      Rails.logger.expects(:error).with(regexp_matches(/AI Validation Error/))

      valid, reason = AiContentValidator.validate("Some text")
      assert valid
      assert_nil reason
    end
  end

  private

    def with_env(env_vars)
      original_env = {}
      env_vars.each do |key, value|
        original_env[key] = ENV[key]
        ENV[key] = value
      end
      yield
    ensure
      original_env.each do |key, value|
        ENV[key] = value
      end
    end
end
