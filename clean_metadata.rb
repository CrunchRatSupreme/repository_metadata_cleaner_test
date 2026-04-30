require "csv"
require "date"

puts "Starting metadata cleanup..."

records = CSV.read("input.csv", headers: true)

puts "Loaded #{records.length} records."

problems = []

records.each do |row|
  next if row["id"].to_s.strip.empty?

  id    = row["id"].to_s.strip
  title = row["title"].to_s.strip
  date  = row["date"].to_s.strip

  if title.empty?
    problems << "Record #{id}: missing title"
  end

  begin
    Date.parse(date)
  rescue ArgumentError
    problems << "Record #{id}: bad date '#{date}'"
  end

end

puts "\nProblems found: #{problems.length}"
problems.each { |p| puts "  - #{p}" }
