class AiContentValidator
  def self.client
    @client ||= OpenAI::Client.new
  end

  def self.validate(text)
    return true if text.blank?

    # Skip if no API key is configured to avoid errors in dev/test without keys
    return true if ENV["OPENAI_ACCESS_TOKEN"].blank?

    begin
      response = client.chat(
        parameters: {
          model: "gpt-4o-mini", # Use a cheaper/faster model
          messages: [
            { role: "system", content: "You are a content moderator for a music education platform. Analyze the user's comment. Check if it is spam, gibberish, offensive, hateful, or sexually explicit. Emojis are allowed and should not be considered gibberish unless used excessively as spam. If it is safe and appropriate, reply with 'SAFE'. If it is inappropriate, reply with 'UNSAFE' followed by a brief reason." },
            { role: "user", content: text }
          ],
          temperature: 0.0,
          max_tokens: 50
        }
      )

      result = response.dig("choices", 0, "message", "content")&.strip

      if result&.start_with?("UNSAFE")
        reason = result.sub("UNSAFE", "").strip.sub(/^:\s*/, "")
        return false, reason.presence || "contains inappropriate content"
      end

      return true, nil
    rescue => e
      Rails.logger.error("AI Validation Error: #{e.message}")
      # Fail open (allow content) if AI service is down, or fail closed depending on requirements.
      # Here we fail open to not block users.
      return true, nil
    end
  end
end
