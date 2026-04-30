require "csv"
require "date"

puts "Starting metadata cleanup..."

records = CSV.read("input.csv", headers: true)

puts "Loaded #{records.length} records."

problems = []

KNOWN_RIGHTS = [
  "CC BY 4.0",
  "CC BY-NC 4.0",
  "CC BY-ND 4.0",
  "CC BY-SA 4.0",
  "Public Domain",
  "Post-print author manuscript"
].freeze

clean_records = []

records.each do |row|
  next if row["id"].to_s.strip.empty?

  id     = row["id"].to_s.strip
  title  = row["title"].to_s.strip
  date   = row["date"].to_s.strip
  rights = row["rights"].to_s.strip

  if title.empty?
    problems << "Record #{id}: missing title"
  end

  begin
    Date.parse(date)
  rescue ArgumentError
    problems << "Record #{id}: bad date '#{date}'"
  end

  if rights.empty?
    problems << "Record #{id}: missing rights statement"
  elsif !KNOWN_RIGHTS.include?(rights)
    problems << "Record #{id}: unrecognised rights '#{rights}'"
  end

  clean_records << {
    "id"         => id,
    "title"      => title,
    "author"     => row["author"].to_s.strip,
    "date"       => date,
    "type"       => row["type"].to_s.strip,
    "department" => row["department"].to_s.strip,
    "abstract"   => row["abstract"].to_s.strip,
    "rights"     => rights
  }
end

CSV.open("cleaned_output.csv", "w") do |csv|
  csv << ["id", "title", "author", "date", "type", "department", "abstract", "rights"]
  clean_records.each { |r| csv << r.values }
end

puts "\nProblems found: #{problems.length}"
problems.each { |p| puts "  - #{p}" }

puts "\nCleaned file written to cleaned_output.csv"