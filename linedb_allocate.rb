require_relative "lib/line_db.rb"
require_relative "lib/line_reader.rb"
require_relative "lib/line_database.rb"

create_db_list_file_mkdir
write_lines(["test"])

test = LineDB.new(db_size: 500, database_partition_amount: 1000)


test["test"].db.new_table!(database_name: "test_database", database_table: "test_table")
# add one billion entries to the table using the database's add method

# add one billion entries to the table using the database's add method
# add one million entries
$incrementor = 0

puts "line_db addition"

a= Time.now
10000.times do |i|
test["test"].db["test_database", "test_table"].add do |hash|  # benchmark with no saves and no additional processing
  hash["database_name"] = "test_database"
  hash["database_table"] = "test_table"
  hash["data"] = "test_data"
  hash["id"] = $incrementor
  puts $incrementor
  $incrementor += 1
end
end
test["test"].db["test_database", "test_table"].save_everything_to_files!
b = Time.now
puts b-a

test["test"].db["test_database", "test_table"].delete_partition!(0)
test["test"].db["test_database", "test_table"].delete_partition!(1)
test["test"].db["test_database", "test_table"].delete_partition!(2)
test["test"].db["test_database", "test_table"].delete_partition!(3)
test["test"].db["test_database", "test_table"].delete_partition!(4)
test["test"].db["test_database", "test_table"].delete_partition!(5)
test["test"].db["test_database", "test_table"].delete_partition!(6)
test["test"].db["test_database", "test_table"].save_everything_to_files!



