namespace :views do
  desc "Check views for potential nil errors"
  task check_nil_errors: :environment do
    puts "🔍 Scanning views for potential nil errors...\n\n"

    views = Dir.glob("app/views/**/*.erb")
    issues = []

    views.each do |view|
      content = File.read(view)
      lines = content.split("\n")

      lines.each_with_index do |line, index|
        line_number = index + 1

        # Check for chained method calls without safe navigation
        if line.match?(/\w+\.\w+\.\w+/) && !line.match?(/&\./)
          # Skip if it's already in a presence check or has try
          next if line.match?(/\.presence/) || line.match?(/\.try/) || line.match?(/if.*\.present\?/)

          issues << {
            file: view,
            line: line_number,
            content: line.strip,
            type: "Chained methods without safe navigation"
          }
        end

        # Check for common nil-prone patterns
        patterns = [
          { regex: /\.teacher\.(?!present\?|blank\?|nil\?|try|&)/, message: "Direct teacher access without nil check" },
          { regex: /\.user\.(?!present\?|blank\?|nil\?|try|&)/, message: "Direct user access without nil check" },
          { regex: /\.student\.(?!present\?|blank\?|nil\?|try|&)/, message: "Direct student access without nil check" },
          { regex: /@\w+\.(?:teacher|user|student|composition)\.(\w+)(?!&\.)/, message: "Optional association accessed without safe navigation" }
        ]

        patterns.each do |pattern|
          if line.match?(pattern[:regex])
            # Skip if already in a presence check
            next if line.match?(/if.*\.present\?/) || line.match?(/unless.*\.nil\?/)

            issues << {
              file: view,
              line: line_number,
              content: line.strip,
              type: pattern[:message]
            }
          end
        end
      end
    end

    if issues.any?
      puts "⚠️  Found #{issues.count} potential nil error(s):\n\n"

      issues.group_by { |i| i[:file] }.each do |file, file_issues|
        puts "📄 #{file}"
        file_issues.each do |issue|
          puts "   Line #{issue[:line]}: #{issue[:type]}"
          puts "   → #{issue[:content]}"
          puts ""
        end
      end

      puts "\n💡 Recommendations:"
      puts "   • Use safe navigation: object&.method"
      puts "   • Add presence checks: if object.present?"
      puts "   • Create helper methods in models"
      puts "   • Use try: object.try(:method)"
    else
      puts "✅ No obvious nil errors found!"
    end
  end
end
