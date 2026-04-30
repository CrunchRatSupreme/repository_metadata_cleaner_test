# Load built-in toolkits
require "csv"
require "date"

# Confirms script is running
puts "Starting metadata cleanup..."

# Check if a filename was passed on the command line (e.g. ruby clean_metadata.rb myfile.csv)
# If not, fall back to "input.csv" as the default.
input_file = ARGV[0] || "input.csv"

puts "Reading from: #{input_file}"

# Load the entire CSV into memory. Confirms file has headers.
records = CSV.read(input_file, headers: true)

puts "Loaded #{records.length} records."

# Two empty buckets created before the loop runs to classify prolems and clean records.
problems = []
clean_records = []

# A fixed list of rights statements considered valid.
KNOWN_RIGHTS = [
  "CC BY 4.0",
  "CC BY-NC 4.0",
  "CC BY-ND 4.0",
  "CC BY-SA 4.0",
  "Public Domain",
  "Post-print author manuscript"
].freeze


# The main loop — goes through every row one at a time, calling it "row".
records.each do |row|
  next if row["id"].to_s.strip.empty?

   # Pull out and clean each field.
  id     = row["id"].to_s.strip
  title  = row["title"].to_s.strip
  date   = row["date"].to_s.strip
  rights = row["rights"].to_s.strip

  # Title check...is it there?
  if title.empty?
    problems << "Record #{id}: missing title"
  end

  # Date check
  begin
    Date.parse(date)
  rescue ArgumentError
    problems << "Record #{id}: bad date '#{date}'"
  end

  # Rights check
  if rights.empty?
    problems << "Record #{id}: missing rights statement"
  elsif !KNOWN_RIGHTS.include?(rights)
    problems << "Record #{id}: unrecognised rights '#{rights}'"
  end

  # Add each row to clean_records as a has to be written to the output CSV later.
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

# Write the cleaned CSV
CSV.open("cleaned_output.csv", "w") do |csv|
  csv << ["id", "title", "author", "date", "type", "department", "abstract", "rights"]
  clean_records.each { |r| csv << r.values }
end

# Print a summary to the terminal.  I don't want to open files if I don't have to right now tbh.
puts "\nProblems found: #{problems.length}"
problems.each { |p| puts "  - #{p}" }

puts "\nCleaned file written to cleaned_output.csv"

# Write the problems report 
File.open("problems_report.txt", "w") do |f|
  f.puts "CORE Scholar Metadata Cleanup Report"
  f.puts "Generated: #{Time.now.strftime('%Y-%m-%d %H:%M')}"
  f.puts "Input file: #{input_file}"
  f.puts "Records processed: #{clean_records.length}"
  f.puts "Problems found: #{problems.length}"
  f.puts ""
  f.puts "=" * 40
  f.puts ""

  if problems.empty?
    f.puts "No problems found!"
  else
    problems.each { |p| f.puts "  - #{p}" }
  end

  f.puts ""
  f.puts "=" * 40
  f.puts "Cleaned output written to: cleaned_output.csv"
end

puts "Problems report written to problems_report.txt"