require "csv"

puts "Starting metadata cleanup..."

records = CSV.read("input.csv", headers: true)

puts "Loaded #{records.length} records."

records.each do |row|
  title = row["title"].to_s.strip

  if title.empty?
    puts "PROBLEM: Record #{row['id']} has no title"
  else
    puts "OK: #{title}"
  end
end
