require_relative "lib/line_db"



#p a[0]

b = LineDB.new(label_integer: true, label_ranges: true)
b["test"].pad.new_table!(database_table: "test", database_name: "test_database")
#p b["aritywolf", "kejento"]
2000.times do |i|
b["test"].pad["test_database", "test"].add do |hash|
  hash[:name] = "name#{i}"
  hash[:age] = i
end

end

#p b["test"].pad["test_database", "test"][0..25]
#p b["test"].db["test_database", "test"][0..25]
#p b["test"].PAD["test_database", "test"][0..25]
b["test"].DB["test_database", "test"][0..3]
p a[0]