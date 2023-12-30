require_relative "lib/line_db"



#p a[0]

b = LineDB.new

b["test"].pad.new_table!(database_table: "test_table", database_name: "test_database")
=begin
300.times do |i|
b["test"].pad["test_database", "test_table"].add do |hash|
  hash[:id] = "#{i}"
end
=end

#end
500.times do |i|
  b["test"].pad["test_database", "test_table"].add do |hash|
    hash[:name] = "name#{i}"
    hash[:age] = i
  end
end

b["test"].pad["test_database", "test_table"].save_everything_to_files!

p b["test"].pad["test_database", "test_table"][0..20]
puts
p b["test"].db["test_database", "test_table"][0..27]
puts
p b["test"].PAD["test_database", "test_table"][0..26]
puts
p b["test"].PAD["test_database", "test_table"][0..26]
p b["test"].PAD["test_database", "test_table"][:all].size



p b["test"].PAD["test_database", "test_table"][:all]
p b["test"].PAD["test_database", "test_table"].data_arr

p b["test"].PAD["test_database", "test_table"].save_everything_to_files!
p b["test"].PAD["test_database", "test_table"].get(499)
p b["test"].PAD["test_database", "test_table"][499]
#.DB["test_database", "test_table"][0,2,4,4,5,5..30][0..3]
#p a[0]