namespace :action_text do
  desc "Replace production URLs with localhost in Action Text content"
  task fix_urls: :environment do
    count = 0

    ActionText::RichText.find_each do |rt|
      original = rt.body.to_s
      updated = original.gsub("https://www.thevivekproject.com", "http://localhost:3000")
                        .gsub("https://thevivekproject.com", "http://localhost:3000")

      if original != updated
        rt.update_column(:body, updated)
        count += 1
        puts "Updated record ##{rt.id}"
      end
    end

    puts "\n✅ Updated #{count} Action Text records"
  end
end
