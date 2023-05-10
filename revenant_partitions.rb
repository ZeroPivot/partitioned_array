require_relative "lib/line_db"
require_relative "lib/line_reader"
require_relative "lib/line_database"



create_db_list_file_mkdir
write_lines(["test"])

test = LineDB.new(db_size: 2, database_partition_amount: 1)
test["test"].db.new_table!(database_name: "test_database", database_table: "test_table")


test["test"].db["test_database", "test_table"].revenant_partition!(0)
test["test"].db["test_database", "test_table"].set(0) do |hash|
  hash["data"] = "test_data234"
end
test["test"].db["test_database", "test_table"].set(1) do |hash|
  hash["data"] = "test_data2344325"
end

test["test"].db["test_database", "test_table"].add do |hash|
  hash["data"] = "test_data_revenant"
end
test["test"].db["test_database", "test_table"].revenant_partition!(0)

0..90.times do |i|
  p test["test"].db["test_database", "test_table"].get(i)
  
end

exit
$incrementor = 0
a= Time.now
80.times do |i|
test["test"].db["test_database", "test_table"].add do |hash|  # benchmark with no saves and no additional processing
  hash["database_name"] = "test_database"
  hash["database_table"] = "test_table"
  hash["data"] = "test_data"
  hash["id"] = $incrementor
  puts $incrementor
  $incrementor += 1
end
end

test["test"].db["test_database", "test_table"].delete_partition!(1)
test["test"].db["test_database", "test_table"].save_everything_to_files!
b = Time.now
puts b-a





p test["test"].db["test_database", "test_table"].get(0)