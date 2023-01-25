require_relative "lib/line_db"



#p a[0]

b = LineDB.new(label_integer: true, label_ranges: true)
b["test"].pad.new_table!(database_table: "test_table", database_name: "test_database")
2000.times do |i|
b["test"].pad["test_database", "test_table"].add do |hash|
  hash[:name] = "name#{i}"
  hash[:age] = i
end

end

p b["test"].pad["test_database", "test_table"][0..20]
puts
p b["test"].db["test_database", "test_table"][0..27]
puts
p b["test"].PAD["test_database", "test_table"][0..26]
puts
b["test", "test"].map do |hash|
 p hash.DB["test_database", "test_table"][9999]
end
#.DB["test_database", "test_table"][0,2,4,4,5,5..30][0..3]
#p a[0]