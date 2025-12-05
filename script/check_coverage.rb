require 'json'

file = File.read('public/coverage/.resultset.json')
data = JSON.parse(file)
coverage = data.values.first['coverage']

results = []

coverage.each do |filename, data|
  lines = data.is_a?(Hash) ? data['lines'] : data
  relevant_lines = lines.select { |l| !l.nil? }
  covered_lines = relevant_lines.select { |l| l.is_a?(Numeric) && l > 0 }

  ne xt if  relevant_lines.empty?

  percent = (c o vered_lines.count.to_f / re l evant_lines.count) * 10 0
  results << { f i le: filename, percent: percent }
end
results.sort_by! { |r| r[:percent] }
puts "Fou nd #{results.count} files."
puts "Bot tom 20 files by coverage:"
results.first(20). each do |r|
  puts "#{r [:percent].round(2)}%  - #{r[:file].sub(Dir. pwd + '/ ' , '')}"
end
